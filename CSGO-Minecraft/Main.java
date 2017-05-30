package fr.goldrush.ostralopitek.gungr;

import code.husky.mysql.Ranks;
import org.bukkit.*;
import org.bukkit.block.Block;
import org.bukkit.command.Command;
import org.bukkit.command.CommandSender;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.entity.*;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.EntityRegainHealthEvent;
import org.bukkit.event.entity.FoodLevelChangeEvent;
import org.bukkit.event.hanging.HangingBreakByEntityEvent;
import org.bukkit.event.inventory.InventoryClickEvent;
import org.bukkit.event.player.*;
import org.bukkit.event.weather.WeatherChangeEvent;
import org.bukkit.inventory.ItemStack;
import org.bukkit.plugin.PluginManager;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.scoreboard.*;

import java.util.ArrayList;
import java.util.List;

import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.*;
import static fr.goldrush.ostralopitek.gungr.TeamManage.*;
import static fr.goldrush.ostralopitek.gungr.GameFunctions.*;
import static org.bukkit.Bukkit.*;
import static org.bukkit.Bukkit.getConsoleSender;

public class Main extends JavaPlugin implements Listener {

    final FileConfiguration config = getConfig();

    @Override
    public void onEnable() {
        PluginManager pm = getServer().getPluginManager();
        pm.registerEvents(this, this);
        loadConfiguration();

        final ScoreboardManager manager = Bukkit.getScoreboardManager();
        final Scoreboard board = manager.getMainScoreboard();

        Ranks.mysqlConnect();

        try {
            board.getObjective("GameStats").unregister();
        } catch (Exception ex) {}

        try {
            board.getObjective("ranks").unregister();
        } catch (Exception ex) {}

        try {
            board.getTeam("1").unregister();
        } catch (Exception ex) {}

        try {
            board.getTeam("2").unregister();
        } catch (Exception ex) {}

        try {
            board.getTeam("Spectator").unregister();
        } catch (Exception e) {}

        try {
            board.getTeam("Started").unregister();
        } catch (Exception e) {}

        try {
            board.getTeam("Lobby").unregister();
        } catch (Exception e) {}

        Objective obj = board.registerNewObjective("GameStats", "dummy");
        obj.getScore("CTRound").setScore(0);
        obj.getScore("TRound").setScore(0);
        obj.getScore("TotRound").setScore(0);
        obj.getScore("Bombe").setScore(0);

        Objective objPage_1 = board.registerNewObjective("ranks", "dummy");
        objPage_1.setDisplayName(ChatColor.AQUA + "Rangs");

        Team teamCT = board.registerNewTeam("1");//CT
        teamCT.setDisplayName(config.getString("1.Nom"));
        teamCT.setNameTagVisibility(NameTagVisibility.HIDE_FOR_OTHER_TEAMS);

        Team teamT = board.registerNewTeam("2");//T
        teamT.setDisplayName(config.getString("2.Nom"));
        teamT.setNameTagVisibility(NameTagVisibility.HIDE_FOR_OTHER_TEAMS);

        board.registerNewTeam("Spectator");
        board.registerNewTeam("Lobby");
        board.registerNewTeam("Started");

        TimerLobby();

        getServer().getScheduler().scheduleSyncDelayedTask(this, new Runnable() {
            public void run() {
                getOverWorld().setStorm(false);
                getOverWorld().setTime(6000);
                getOverWorld().setGameRuleValue("doDayLightCycle", "false");
            }
        }, 10L);
    }

    @Override
    public boolean onCommand(final CommandSender sender, Command cmd, String label, String[] args) {

        Player player = (Player) sender;

        if (cmd.getName().equalsIgnoreCase("gungr")) {
            if(args.length == 0) {
                sender.sendMessage(ChatColor.RED + "/gungr help pour voir la liste des commandes");
                return true;
            }
            //Boutique
            if(args[0].equalsIgnoreCase("inv")) {
                Shop.mainMenu(player);
                return true;
            }
            //Start
            else if(args[0].equalsIgnoreCase("start")) {
                Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
                int timerid = mainBoard.getObjective("GameStats").getScore("timerLobbyID").getScore();
                getServer().getScheduler().cancelTask(timerid);

                OnGameStart();
                return true;
            }
            //Money
            else if(args[0].equalsIgnoreCase("money")) {
                int money = Integer.parseInt(args[1]);
                setPlayerMoney(player, money);
                return true;
            }
            //Help
            else if(args[0].equalsIgnoreCase("help")) {
                player.sendMessage(ChatColor.GOLD + "==========Liste des commandes==========");
                player.sendMessage(ChatColor.GOLD + "/gungr inv : " + ChatColor.AQUA + "Ouvrir la boutique");
                player.sendMessage(ChatColor.GOLD + "/gungr start : " + ChatColor.AQUA + "Démarrer la partie");
                player.sendMessage(ChatColor.GOLD + "/gungr stop : " + ChatColor.AQUA + "Arrêter la partie");
                player.sendMessage(ChatColor.GOLD + "/gungr help : " + ChatColor.AQUA + "Ouvrir cette page");
                return true;
            }
            else {
                sender.sendMessage(ChatColor.RED + "/gungr help pour voir la liste des commandes");
                return true;
            }
        }
        else if (cmd.getName().equalsIgnoreCase("fly")) {
            if(GameStatus() == 0) {
                player.setFlying(true);
                player.sendMessage(ChatColor.GREEN + "Fly activé");
                return true;
            }
        }

        return false;
    }

    @EventHandler
    public void OnReload(PlayerDropItemEvent event) {
        event.setCancelled(true);
        if(GameStatus() == 0) return;

        Player player = event.getPlayer();

        //Reload
        Material itemInHand;
        try {
            itemInHand = event.getItemDrop().getItemStack().getType();
        } catch (Exception ex) {return;}

        int slot = player.getInventory().getHeldItemSlot();

        //Carrotte == M4
        if (slot == 0) {
            ItemStack ISammoInStock = player.getInventory().getItem(7);
            ItemStack ISmagazine = player.getInventory().getItem(1);
            if(ISammoInStock == null || ISmagazine == null) return;

            //S'il n'y a plus rien dans le chargeur
            if(ISammoInStock.getType() == Material.MILK_BUCKET || ISammoInStock.getType() == null) return;

            int maxAmmoInMagazine = Weapons.getAmmoInMagazine(itemInHand);
            int ammoInMagazine = ISmagazine.getAmount();
            int ammoInStock = ISammoInStock.getAmount();
            if(ammoInMagazine >= maxAmmoInMagazine) return;
            if(ISmagazine.getType() == Material.MILK_BUCKET || ISmagazine.getType() == null) {
                ammoInMagazine = 0;
            }

            int newAmmoInMagazine;
            int newAmmoInStock;
            ItemStack ISstock;

            if(ammoInMagazine < maxAmmoInMagazine && ammoInStock < maxAmmoInMagazine) {
                if(ammoInMagazine + ammoInStock <= 20) {
                    newAmmoInMagazine = ammoInMagazine + ammoInStock;
                } else {
                    newAmmoInMagazine = maxAmmoInMagazine;
                }
                newAmmoInStock = ammoInStock - (maxAmmoInMagazine - ammoInMagazine);
                if(newAmmoInStock < 0) {
                    ISstock = new ItemStack(Material.MILK_BUCKET);
                    ISstock = setName(ISstock, ChatColor.RED + "Plus de muntions", null);
                } else {
                    ISstock = new ItemStack(Material.GLOWSTONE_DUST, newAmmoInStock);
                    ISstock = setName(ISstock, ChatColor.RED + "Munitions(arme principale)", null);
                }
            }
            else if(ammoInStock - maxAmmoInMagazine < 0) {
                newAmmoInMagazine = ammoInMagazine + ammoInStock;
                ISstock = new ItemStack(Material.MILK_BUCKET);
                ISstock = setName(ISstock, ChatColor.RED + "Plus de muntions", null);
            }
            else {
                newAmmoInMagazine = maxAmmoInMagazine;
                newAmmoInStock = ammoInStock - (maxAmmoInMagazine - ammoInMagazine);
                ISstock = new ItemStack(Material.GLOWSTONE_DUST, newAmmoInStock);
                ISstock = setName(ISstock, ChatColor.RED + "Munitions(arme principale)", null);
            }

            ItemStack ISammo = new ItemStack(Material.GLOWSTONE_DUST, newAmmoInMagazine);
            ISammo = setName(ISammo, ChatColor.RED + "Munitions(arme principale)", null);
            player.getInventory().setItem(1, ISammo);
            player.getInventory().setItem(7, ISstock);

        }
        else if(slot == 2) {
            ItemStack ISammoInStock = player.getInventory().getItem(8);
            ItemStack ISmagazine = player.getInventory().getItem(3);
            if(ISammoInStock == null || ISmagazine == null) return;

            //S'il n'y a plus rien dans le chargeur
            if(ISammoInStock.getType() == Material.MILK_BUCKET || ISammoInStock.getType() == null) return;

            int maxAmmoInMagazine = Weapons.getAmmoInMagazine(itemInHand);
            int ammoInMagazine = ISmagazine.getAmount();
            int ammoInStock = ISammoInStock.getAmount();
            if(ammoInMagazine >= maxAmmoInMagazine) return;
            if(ISmagazine.getType() == Material.MILK_BUCKET || ISmagazine.getType() == null) {
                ammoInMagazine = 0;
            }

            int newAmmoInMagazine;
            int newAmmoInStock;
            ItemStack ISstock;

            if(ammoInMagazine < maxAmmoInMagazine && ammoInStock < maxAmmoInMagazine) {
                if(ammoInMagazine + ammoInStock <= Weapons.getAmmoInMagazine(itemInHand)) {
                    newAmmoInMagazine = ammoInMagazine + ammoInStock;
                } else {
                    newAmmoInMagazine = maxAmmoInMagazine;
                }
                newAmmoInStock = ammoInStock - (maxAmmoInMagazine - ammoInMagazine);
                if(newAmmoInStock < 0) {
                    ISstock = new ItemStack(Material.MILK_BUCKET);
                    ISstock = setName(ISstock, ChatColor.RED + "Plus de muntions", null);
                } else {
                    ISstock = new ItemStack(Material.DEAD_BUSH, newAmmoInStock);
                    ISstock = setName(ISstock, ChatColor.RED + "Munitions(arme secondaire)", null);
                }
            }
            else if(ammoInStock - maxAmmoInMagazine < 0) {
                newAmmoInMagazine = ammoInMagazine + ammoInStock;
                ISstock = new ItemStack(Material.MILK_BUCKET);
                ISstock = setName(ISstock, ChatColor.RED + "Plus de muntions", null);
            }
            else {
                newAmmoInMagazine = maxAmmoInMagazine;
                newAmmoInStock = ammoInStock - (maxAmmoInMagazine - ammoInMagazine);
                ISstock = new ItemStack(Material.DEAD_BUSH, newAmmoInStock);
                ISstock = setName(ISstock, ChatColor.RED + "Munitions(arme secondaire)", null);
            }

            ItemStack ISammo = new ItemStack(Material.DEAD_BUSH, newAmmoInMagazine);
            ISammo = setName(ISammo, ChatColor.RED + "Munitions(arme secondaire)", null);
            player.getInventory().setItem(3, ISammo);
            player.getInventory().setItem(8, ISstock);
        }
        else return;

        //Executer l'animation
        double reloadTime = Weapons.getReloadTime(itemInHand);
        reloadExp(player, reloadTime);
    }

    @EventHandler
    public void OnMove(PlayerMoveEvent e) {
        Player player = e.getPlayer();
        Location from = e.getFrom();
        if(GameStatus() == 2 && (from.getZ() != e.getTo().getZ() || from.getX() != e.getTo().getX())) {
            if(player.getGameMode() != GameMode.SPECTATOR) {
                player.teleport(e.getFrom());
            }
        }
    }

    @EventHandler
    public void OnRegeneration(EntityRegainHealthEvent event) {
        if(GameStatus() != 0) event.setCancelled(true);
    }

    @EventHandler
    public void OnInteractWithEntity(PlayerInteractEntityEvent event) {
        final Player player = event.getPlayer();

        playerShoot(player);
    }

    @EventHandler
    public void OnClick(PlayerInteractEvent event) {
        final Player player = event.getPlayer();
        Block targetBlock = null;
        try {
            targetBlock = getTargetBlock(player, 6);
        } catch (Exception ex) {}

        ItemStack currentItem = player.getItemInHand();
        if(currentItem == null) return;
        if(currentItem.getType() == Material.WRITTEN_BOOK) return;

        if(targetBlock != null) {
            Material block = targetBlock.getType();
            //Si le joueur a un kit de désamorçage ou une bombe
            if (currentItem.getType() != Material.WOOD_PICKAXE
                    && currentItem.getType() != Material.STONE_PICKAXE
                    && currentItem.getType() != Material.OBSIDIAN
                    && block != Material.DIAMOND_BLOCK
                    && block != Material.JUKEBOX
                    || event.getAction() != Action.LEFT_CLICK_BLOCK) {
                event.setCancelled(true);
            }
        }


        //Si la partie n'est pas commencée (Laines)
        if(GameStatus() == 0) {
            TeamItemsUpdate(player);
            return;
        }

        String displayName;
        try {
            displayName = currentItem.getItemMeta().getDisplayName();
        } catch(Exception ex) {return;}

        if(displayName != null) {
            if (currentItem.getItemMeta().getDisplayName().contains("Boutique")) {
                if (getValue("buyable") == 1 && getValue("Bombe") == 0) {
                    Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
                    Location pLoc = player.getLocation();
                    String tName = mainBoard.getPlayerTeam(player).getName();
                    Location spawnLoc = new Location(getOverWorld(), config.getInt(tName + ".Spawn.posX"), config.getInt(tName + ".Spawn.posY"), config.getInt(tName + ".Spawn.posZ"));
                    if (pLoc.distance(spawnLoc) <= 15) {
                        Shop.mainMenu(player);
                    } else {
                        player.sendMessage(ChatColor.RED + "Tu dois être proche de ton point d'apparition pour accéder à la boutique");
                    }
                }
                else player.sendMessage(ChatColor.RED + "Tu ne peux pas acheter d'arme après 1:40 de jeu");
                return;
            }
        }

        //Regarde le type d'arme(main, secondaire, couteau)
        int weaponType = player.getInventory().getHeldItemSlot();

        //Cut en clic droit
        Player target = getTargetPlayer(player);

        //Empêcher le TK
        if(sameTeams(player, target)) return;
        if(target != null) {
            if (target.getGameMode() == GameMode.SPECTATOR) return;
        }

        if (event.getAction() == Action.RIGHT_CLICK_AIR || event.getAction() == Action.RIGHT_CLICK_BLOCK) {
            //Couteau au clic droit
            if(weaponType == 4) {
                if (target instanceof Player) {
                    Player cuttedLook = getTargetPlayer(target);
                    if(target.getLocation().distance(player.getLocation()) <= 1.5) {
                        double damage;
                        if (cuttedLook instanceof Player) damage = 11.0;
                        else damage = 7.0;
                        if (damage >= target.getHealth()) {
                            OnDeath(player, target);
                        }

                        getOverWorld().playSound(player.getLocation(), Sound.CAT_HIT, 25, 1);
                        playDamage(target, damage);
                    }
                }
            }
            return;
        }
        playerShoot(player);
    }

    @EventHandler
    public void PickUp(PlayerPickupItemEvent event) {
        if(event.getItem().getItemStack().getType() == Material.OBSIDIAN) {
            Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
            Player player = event.getPlayer();
            if(mainBoard.getPlayerTeam(player) == mainBoard.getTeam("2")) {
                player.getInventory().setItem(5, event.getItem().getItemStack());
            }
        }
    }

    @EventHandler
    public void OnQuit(PlayerQuitEvent event) {
        Player player = event.getPlayer();
        Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
        Team team;

        if(GameStatus() == 0) {
            String rank_name = Ranks.getRankName(player);
            mainBoard.resetScores(ChatColor.DARK_AQUA + player.getName() + " : " + ChatColor.AQUA + rank_name);
            return;
        }

        try {
            team = mainBoard.getPlayerTeam(player);
        } catch (Exception ex) {return;}

        //Ajouter dans le scoreboard de chaque joueur les équipes
        for(Player online : getServer().getOnlinePlayers()) {
            Scoreboard pBoard = Bukkit.getScoreboardManager().getNewScoreboard();
            if(online.getGameMode() != GameMode.SPECTATOR) {
                Team teamCT = pBoard.registerNewTeam("1");
                Team teamT = pBoard.registerNewTeam("2");
                for (OfflinePlayer CTplayer : mainBoard.getTeam("1").getPlayers()) {
                    teamCT.removePlayer(CTplayer);
                }
                for (OfflinePlayer Tplayer : mainBoard.getTeam("2").getPlayers()) {
                    teamT.removePlayer(Tplayer);
                }
            }
        }

        int ct = mainBoard.getTeam("1").getPlayers().size();
        int t = mainBoard.getTeam("2").getPlayers().size();

        if(getValue("CTRound") < 8 && getValue("TRound") < 8 &&
                !mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Spectator").getName()) &&
                !mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Lobby").getName()) &&
                ct > 0 && t > 0) {
            Ranks.setElo(player, Ranks.getElo(player) - 30);
        }

        //Vérifie s'il y a encore des survivants dans l'équipe du quitteur
        int sizeTeam = team.getSize();
        int deadMember = 0;
        for(OfflinePlayer tM : team.getPlayers()) {
            Player teamMember = (Player) tM;
            if(teamMember.getGameMode() == GameMode.SPECTATOR) {
                deadMember++;
            }
        }
        //Enlève le joeur de sa team
        if(team != null) team.removePlayer(player);

        //Si tout le monde est mort
        if(sizeTeam <= deadMember && getValue("Bombe") == 1 && team.getName().equals(mainBoard.getTeam("2").getName())) {
            sendMessage(ChatColor.GREEN + "Tous les terroristes sont morts. Les anti-terroristes doivent maintenant désamorçer la bombe");
            OnRoundEnd(mainBoard.getPlayerTeam(player));
        }

        //Si il n'y a plus personne dans chacune des équipes
        if(ct == 0 || t ==0) {
            getServer().dispatchCommand(getConsoleSender(), "sendplayer all Hub_1");
            getServer().dispatchCommand(getConsoleSender(), "rl");
            return;
        }
    }

    @EventHandler
    public void OnBlockBreak(BlockBreakEvent event) {
        Material block = event.getBlock().getType();
        final Scoreboard mainBoard = Bukkit.getScoreboardManager().getMainScoreboard();
        final Player player = event.getPlayer();
        event.setCancelled(true);
        if(block == Material.JUKEBOX) {
            //Bombe plantée
            if(mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("2").getName())) {
                if(getValue("Bombe") == 1) return;
                if(GameStatus() != 3) player.sendMessage(ChatColor.RED + "Tu ne pas planter la bombe maintenant");
                if(player.getItemInHand() != null) {
                    if(player.getItemInHand().getType() != Material.OBSIDIAN) {
                        player.sendMessage(ChatColor.RED + "Tu dois avoir la bombe en main pour la planter");
                        return;
                    }
                }
                //Il pose la bombe
                event.setCancelled(true);
                Location bombLoc = event.getBlock().getLocation();
                bombLoc.setY(bombLoc.getBlockY() + 1);
                mainBoard.getObjective("GameStats").getScore("bombeX").setScore(bombLoc.getBlockX());
                mainBoard.getObjective("GameStats").getScore("bombeY").setScore(bombLoc.getBlockY());
                mainBoard.getObjective("GameStats").getScore("bombeZ").setScore(bombLoc.getBlockZ());
                setPlayerBomb(player, getPlayerBomb(player) + 1);
                setValue("Bombe", 1);
                int bombTid = getServer().getScheduler().scheduleSyncDelayedTask(this, new Runnable() {
                    @Override
                    public void run() {
                        //Fait l'explosion de la bombe
                        int posX = mainBoard.getObjective("GameStats").getScore("bombeX").getScore();
                        int posY = mainBoard.getObjective("GameStats").getScore("bombeY").getScore();
                        int posZ = mainBoard.getObjective("GameStats").getScore("bombeZ").getScore();
                        Location bombLoc = new Location(getOverWorld(), posX, posY, posZ);
                        getOverWorld().playSound(bombLoc, Sound.AMBIENCE_CAVE, 150, 1);
                        //Fait des dommages à l'explosion
                        for(Player online : getServer().getOnlinePlayers()) {
                            if(online.getGameMode() != GameMode.SPECTATOR) {
                                if(online.getLocation().distance(bombLoc) <= 35) {
                                    if (online.getHealth() <= 12.5) OnDeath(null, online);
                                    else playDamage(online, 12.5);
                                }
                            }
                        }
                        OnRoundEnd(mainBoard.getTeam("1"));
                    }
                },900L);

                mainBoard.getObjective("GameStats").getScore("bombTid").setScore(bombTid);

                getOverWorld().getBlockAt(bombLoc).setType(Material.DIAMOND_BLOCK);
                getOverWorld().playSound(bombLoc, Sound.LEVEL_UP, 1, 1);
            }
        }
        else if(block == Material.DIAMOND_BLOCK) {
            if(mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("1").getName())) {
                int posX = mainBoard.getObjective("GameStats").getScore("bombeX").getScore();
                int posY = mainBoard.getObjective("GameStats").getScore("bombeY").getScore();
                int posZ = mainBoard.getObjective("GameStats").getScore("bombeZ").getScore();
                Location bombLoc = new Location(getOverWorld(), posX, posY, posZ);
                //Les T perdent
                OnRoundEnd(mainBoard.getTeam("2"));
                Weapons.bombRemove();
                setPlayerBomb(player, getPlayerBomb(player) + 1);
                //Donner l'argent aux CT
                for (OfflinePlayer CT : mainBoard.getTeam("1").getPlayers()) {
                    Player CTplayer = (Player) CT;
                    setPlayerMoney(CTplayer, getPlayerMoney(CTplayer) + 300);
                }
                //Fait l'explosion de la bombe
                getOverWorld().playSound(bombLoc, Sound.BAT_HURT, 1, 1);
                setValue("Bombe", 0);
            }
        }
        //Ajouter au scoreboard GameStats la defuse/pose
        String pName = ChatColor.stripColor(player.getDisplayName());
        int defuse = mainBoard.getObjective("GameStats").getScore("d" + pName).getScore();
        mainBoard.getObjective("GameStats").getScore("d" + pName).setScore(defuse + 1);
    }

    @EventHandler
    public void OnWheatherChange(WeatherChangeEvent event) {
        event.setCancelled(true);
    }

    @EventHandler
    public void OnFoodLevelChange(FoodLevelChangeEvent event) {
        event.setCancelled(true);
    }

    @EventHandler
    public void OnPlayerDamage(EntityDamageEvent event) {

        if(GameStatus() == 0) event.setCancelled(true);

        //Réduire les dégâts de chute
        else if(event.getEntity() instanceof Player) {
            if(event.getCause() == EntityDamageEvent.DamageCause.FALL) {
                Player player = (Player) event.getEntity();
                if(player.getFallDistance() <= 7) event.setCancelled(true);
                else {
                    double damage = event.getDamage() / 3;
                    if(damage < player.getHealth()) {
                        event.setDamage(damage);
                    }
                    else {
                        OnDeath(null, player);
                    }
                }
            }
        }
    }

    @EventHandler
    public void OnItemFramePunch(EntityDamageByEntityEvent event) {
        if(event.getDamager() instanceof ItemFrame) {
            event.setCancelled(true);
        }
    }
    @EventHandler
    public void OnItemFrameBreak(HangingBreakByEntityEvent event) {
        if(event.getEntity() instanceof  ItemFrame
                || event.getEntity() instanceof Painting) {
            event.setCancelled(true);
        }
    }

    @EventHandler
    public void InventoryClick(InventoryClickEvent e) {
        Player player = (Player) e.getWhoClicked();

        e.setCancelled(true);

        if (e.getCurrentItem() == null) {
            return;
        }
        String item;
        try {
            item = e.getCurrentItem().getItemMeta().getDisplayName();
        } catch (Exception ex) {return;}

        if (e.getInventory().getTitle().contains("Boutique")) {

            if (item.contains("FUSILS")) {
                Shop.fusilsMenu(player);
            }
            else if (item.contains("PMs")) {
                //Shop.pmsMenu(player);
                player.sendMessage(ChatColor.RED + "Seuls les fusils sont disponibles actuellement");
            }
            else if (item.contains("LOURDES")) {
                //Shop.lourdesMenu(player);
                player.sendMessage(ChatColor.RED + "Seuls les fusils sont disponibles actuellement");
            }
            else if(e.getCurrentItem().getType() == Material.getMaterial(config.getInt("Weapons.KIT.ItemID"))) {
                //Ajouter le kit de désamorçage
                String item_name = Weapons.getName(e.getCurrentItem().getType());
                ItemStack ISkit = new ItemStack(Material.getMaterial(config.getInt("Weapons.KIT.ItemID")), 1);
                ISkit = setName(ISkit, ChatColor.GOLD + item_name, null);
                player.getInventory().setItem(5, ISkit);
                int price = config.getInt("Weapons.KIT.Price");
                setPlayerMoney(player, getPlayerMoney(player) - price);
                player.closeInventory();
            }
        }
        else if(e.getInventory().getTitle().contains("Fusils")
                || e.getInventory().getTitle().contains("Lourdes")
                || e.getInventory().getTitle().contains("Pistolets Mitrailleurs")) {

            String item_name = ChatColor.stripColor(item);
            int price = config.getInt("Weapons." + item_name + ".Price");
            if(getPlayerMoney(player) >= price) {
                setPlayerMoney(player, getPlayerMoney(player) - price);
                Weapons.addWeapon(player, item_name, "primary");
            }
            else {
                player.sendMessage(ChatColor.RED + "Tu n'as pas assez d'argent pour acheter cette arme");
                return;
            }
            player.closeInventory();
        }
    }

    @EventHandler
    public void OnJoin(final PlayerJoinEvent event) {
        final Scoreboard board = Bukkit.getScoreboardManager().getMainScoreboard();

        final Player player = event.getPlayer();
        event.setJoinMessage(ChatColor.BLUE + "[GunGR] " + ChatColor.YELLOW + player.getDisplayName() + " a rejoint la partie");

        getServer().getScheduler().scheduleSyncDelayedTask(this, new Runnable() {
            @Override
            public void run() {
                if (GameStatus() == 0) {
                    player.getInventory().clear();
                    player.setFoodLevel(20);
                    player.setSaturation(20);
                    player.setHealth(20);
                    player.setGameMode(GameMode.ADVENTURE);
                    ItemsSet();
                    //Ajouter au Scoreboard des classements
                    String rank_name = Ranks.getRankName(player);
                    int rank_id = Ranks.getRankID(Ranks.getElo(player));
                    player.setScoreboard(board);
                    Objective objPage = board.getObjective("ranks");
                    if(Ranks.getWin(player) >= 5) {
                        objPage.getScore(ChatColor.DARK_AQUA + player.getName() + " : " + ChatColor.AQUA + rank_name).setScore(rank_id);
                    }
                    else {
                        objPage.getScore(ChatColor.DARK_AQUA + player.getName() + " : " + ChatColor.AQUA + Ranks.getRankName(0)).setScore(rank_id);
                    }
                    objPage.setDisplaySlot(DisplaySlot.SIDEBAR);

                } else {
                    board.getTeam("Spectator").addPlayer(player);
                    player.setGameMode(GameMode.SPECTATOR);
                }
                Player player = event.getPlayer();
                Location spawnLoc = getOverWorld().getSpawnLocation();
                player.teleport(spawnLoc);
            }
        }, 20L);
    }

    public void loadConfiguration() {
        List<Integer> ls = new ArrayList<>();
        ls.add(20);
        ls.add(1);

        config.addDefault("MinPlayers", 2);
        config.addDefault("LobbyTime", 3);

        config.addDefault("1.Nom", "Anti-Terroristes");
        config.addDefault("1.Spawn.posX", 0);
        config.addDefault("1.Spawn.posY", 66);
        config.addDefault("1.Spawn.posZ", 0);

        config.addDefault("2.Nom", "Terroristes");
        config.addDefault("2.Spawn.posX", 0);
        config.addDefault("2.Spawn.posY", 66);
        config.addDefault("2.Spawn.posZ", 0);

        //FAMAS
        config.addDefault("Weapons.FAMAS.ItemID", 423);
        config.addDefault("Weapons.FAMAS.Magazine", 25);
        config.addDefault("Weapons.FAMAS.Ammo", 80);
        config.addDefault("Weapons.FAMAS.Precision", 90);
        config.addDefault("Weapons.FAMAS.Damage", 2.0);
        config.addDefault("Weapons.FAMAS.Price", 2250);
        config.addDefault("Weapons.FAMAS.FireTime", 2L);
        config.addDefault("Weapons.FAMAS.ReloadTime", 2);
        config.addDefault("Weapons.FAMAS.DamageDist", 30);
        //M4A1-S
        config.addDefault("Weapons.M4A1-S.ItemID", 391);
        config.addDefault("Weapons.M4A1-S.Magazine", 20);
        config.addDefault("Weapons.M4A1-S.Ammo", 40);
        config.addDefault("Weapons.M4A1-S.Precision", 90);
        config.addDefault("Weapons.M4A1-S.Damage", 2.5);
        config.addDefault("Weapons.M4A1-S.Price", 3200);
        config.addDefault("Weapons.M4A1-S.FireTime", 2L);
        config.addDefault("Weapons.M4A1-S.ReloadTime", 2);
        config.addDefault("Weapons.M4A1-S.DamageDist", 30);
        //AK 47
        config.addDefault("Weapons.AK-47.ItemID", 392);
        config.addDefault("Weapons.AK-47.Magazine", 30);
        config.addDefault("Weapons.AK-47.Ammo", 90);
        config.addDefault("Weapons.AK-47.Precision", 85);
        config.addDefault("Weapons.AK-47.Damage", 3.35);
        config.addDefault("Weapons.AK-47.Price", 2700);
        config.addDefault("Weapons.AK-47.FireTime", 2L);
        config.addDefault("Weapons.AK-47.ReloadTime", 2);
        config.addDefault("Weapons.AK-47.DamageDist", 40);
        //SSG 08
        config.addDefault("Weapons.SSG_08.ItemID", 424);
        config.addDefault("Weapons.SSG_08.Magazine", 10);
        config.addDefault("Weapons.SSG_08.Ammo", 90);
        config.addDefault("Weapons.SSG_08.Precision", 100);
        config.addDefault("Weapons.SSG_08.Damage", 8.0);
        config.addDefault("Weapons.SSG_08.Price", 1700);
        config.addDefault("Weapons.SSG_08.FireTime", 10L);
        config.addDefault("Weapons.SSG_08.ReloadTime", 2.5);
        config.addDefault("Weapons.SSG_08.DamageDist", 70);
        //AUG
        config.addDefault("Weapons.AUG.ItemID", 282);
        config.addDefault("Weapons.AUG.Magazine", 30);
        config.addDefault("Weapons.AUG.Ammo", 90);
        config.addDefault("Weapons.AUG.Precision", 85);
        config.addDefault("Weapons.AUG.Damage", 3.35);
        config.addDefault("Weapons.AUG.Price", 3300);
        config.addDefault("Weapons.AUG.FireTime", 3L);
        config.addDefault("Weapons.AUG.ReloadTime", 2.5);
        config.addDefault("Weapons.AUG.DamageDist", 50);
        //SG 553
        config.addDefault("Weapons.SG_553.ItemID", 260);
        config.addDefault("Weapons.SG_553.Magazine", 30);
        config.addDefault("Weapons.SG_553.Ammo", 90);
        config.addDefault("Weapons.SG_553.Precision", 85);
        config.addDefault("Weapons.SG_553.Damage", 3.35);
        config.addDefault("Weapons.SG_553.Price", 3000);
        config.addDefault("Weapons.SG_553.FireTime", 3L);
        config.addDefault("Weapons.SG_553.ReloadTime", 2.5);
        config.addDefault("Weapons.SG_553.DamageDist", 50);
        //AWP
        config.addDefault("Weapons.AWP.ItemID", 412);
        config.addDefault("Weapons.AWP.Magazine", 10);
        config.addDefault("Weapons.AWP.Ammo", 30);
        config.addDefault("Weapons.AWP.Precision", 70);
        config.addDefault("Weapons.AWP.Damage", 20.0);
        config.addDefault("Weapons.AWP.Price", 4750);
        config.addDefault("Weapons.AWP.FireTime", 40L);
        config.addDefault("Weapons.AWP.ReloadTime", 4);
        config.addDefault("Weapons.AWP.DamageDist", 100);
        //Auto
        config.addDefault("Weapons.AUTO.ItemID", 411);
        config.addDefault("Weapons.AUTO.Magazine", 20);
        config.addDefault("Weapons.AUTO.Ammo", 90);
        config.addDefault("Weapons.AUTO.Precision", 90);
        config.addDefault("Weapons.AUTO.Damage", 8.2);
        config.addDefault("Weapons.AUTO.Price", 5000);
        config.addDefault("Weapons.AUTO.FireTime", 10L);
        config.addDefault("Weapons.AUTO.ReloadTime", 4);
        config.addDefault("Weapons.AUTO.DamageDist", 70);


        //GLOCK-18
        config.addDefault("Weapons.GLOCK-18.ItemID", 390);
        config.addDefault("Weapons.GLOCK-18.Magazine", 20);
        config.addDefault("Weapons.GLOCK-18.Ammo", 120);
        config.addDefault("Weapons.GLOCK-18.Precision", 92);
        config.addDefault("Weapons.GLOCK-18.Damage", 1.0);
        config.addDefault("Weapons.GLOCK-18.Price", 200);
        config.addDefault("Weapons.GLOCK-18.FireTime", 2);
        config.addDefault("Weapons.GLOCK-18.ReloadTime", 1.5);
        //USP-S
        config.addDefault("Weapons.USP-S.ItemID", 396);
        config.addDefault("Weapons.USP-S.Magazine", 12);
        config.addDefault("Weapons.USP-S.Ammo", 24);
        config.addDefault("Weapons.USP-S.Precision", 96);
        config.addDefault("Weapons.USP-S.Damage", 1.2);
        config.addDefault("Weapons.USP-S.Price", 200);
        config.addDefault("Weapons.USP-S.FireTime", 3);
        config.addDefault("Weapons.USP-S.ReloadTime", 1.5);
        //P250
        config.addDefault("Weapons.P250.ItemID", 393);
        config.addDefault("Weapons.P250.Magazine", 13);
        config.addDefault("Weapons.P250.Ammo", 26);
        config.addDefault("Weapons.P250.Precision", 90);
        config.addDefault("Weapons.P250.Damage", 1.4);
        config.addDefault("Weapons.P250.Price", 300);
        config.addDefault("Weapons.P250.FireTime", 3);
        config.addDefault("Weapons.P250.ReloadTime", 2);

        //NOVA
        config.addDefault("Weapons.NOVA.ItemID", 394);
        config.addDefault("Weapons.NOVA.Magazine", 8);
        config.addDefault("Weapons.NOVA.Ammo", 35);
        config.addDefault("Weapons.NOVA.Precision", 80);
        config.addDefault("Weapons.NOVA.Damage", 6.5);
        config.addDefault("Weapons.NOVA.Price", 1200);
        config.addDefault("Weapons.NOVA.FireTime", 10);
        config.addDefault("Weapons.NOVA.ReloadTime", 2);

        //P90
        config.addDefault("Weapons.P90.ItemID", 395);
        config.addDefault("Weapons.P90.Magazine", 50);
        config.addDefault("Weapons.P90.Ammo", 100);
        config.addDefault("Weapons.P90.Precision", 65);
        config.addDefault("Weapons.P90.Damage", 1.7);
        config.addDefault("Weapons.P90.Price", 2350);
        config.addDefault("Weapons.P90.FireTime", 1);
        config.addDefault("Weapons.P90.ReloadTime", 2.25);

        //Kit
        config.addDefault("Weapons.KIT.ItemID", 274);
        config.addDefault("Weapons.KIT.Price", 400);

        config.options().copyDefaults(true);
        saveConfig();
    }
}