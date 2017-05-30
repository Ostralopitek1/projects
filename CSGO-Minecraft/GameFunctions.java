package fr.goldrush.ostralopitek.gungr;

import code.husky.mysql.Ranks;
import org.bukkit.*;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.plugin.Plugin;
import org.bukkit.potion.PotionEffect;
import org.bukkit.potion.PotionEffectType;
import org.bukkit.scoreboard.*;

import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.*;
import static org.bukkit.Bukkit.*;

public class GameFunctions {

    static Plugin plugin = getPluginManager().getPlugin("GunGR");
    static final FileConfiguration config = plugin.getConfig();

    //OnGameStart
    public static void OnGameStart() {

        //Ajoute le joueur à une équipe
        final Scoreboard mainBoard = Bukkit.getScoreboardManager().getMainScoreboard();
        getServer().dispatchCommand(getConsoleSender(), "status 2");

        //Mettre tout le monde dans la team Lobby
        for(Player online : getServer().getOnlinePlayers()) {
            mainBoard.getTeam("Lobby").addPlayer(online);
        }

        int players = getServer().getOnlinePlayers().size();
        int teamSize = players / 2;
        for(int i = 1; i <= 2; i++) {
            Team team = mainBoard.getTeam("" + i);
            int newTeamSize = team.getSize();
            if(newTeamSize > teamSize) {
                for(OfflinePlayer offlinePlayer : team.getPlayers()) {
                    mainBoard.getTeam("Lobby").addPlayer(offlinePlayer);
                    break;
                }
            }
        }

        //Assignation d'une équipe aux joueurs qui sont dans la team Lobby
        for(OfflinePlayer playerInLobby : mainBoard.getTeam("Lobby").getPlayers()) {
            for(int i = 1; i <= 2; i++) {
                Team team = mainBoard.getTeam("" + i);
                if(team.getSize() < teamSize) {
                    team.addPlayer(playerInLobby);
                    break;
                }
            }
        }

        //Assignation d'une équipe aux joueurs qu'il reste
        int o = 1;
        for(OfflinePlayer playerInLobby : mainBoard.getTeam("Lobby").getPlayers()) {
            for(int i = o; i <= 2; i++) {
                Player playerLobby = (Player) playerInLobby;
                Team team = mainBoard.getTeam("" + i);
                team.addPlayer(playerLobby);
                o++;
                break;
            }
        }

        for(int i = 1; i <= 2; i++) {
            Team team = mainBoard.getTeam("" + i);
            for(OfflinePlayer tM : team.getPlayers()) {
                Player teamMember = (Player) tM;
                //Ajouter les items au respawn
                if(i == 1) teamMember.setPlayerListName(ChatColor.BLUE + teamMember.getDisplayName());
                else if(i == 2) teamMember.setPlayerListName(ChatColor.GOLD + teamMember.getDisplayName());
                teamMember.setGameMode(GameMode.SURVIVAL);
                teamMember.setFoodLevel(20);
                teamMember.setSaturation(20);
                teamMember.setHealth(20);
                teamMember.getInventory().clear();
                teamMember.sendMessage(ChatColor.GREEN + "La partie a débutée.");
            }
        }

        //Si le joueur n'a été assigné à aucune équipe
        for(Player online : getServer().getOnlinePlayers()) {
            if(mainBoard.getPlayerTeam(online) == null || mainBoard.getPlayerTeam(online) == mainBoard.getTeam("Lobby")) {
                //On l'ajoute aux spectateurs
                mainBoard.getTeam("Spectator").addPlayer(online);
                online.setGameMode(GameMode.SPECTATOR);
                online.sendMessage(ChatColor.RED + "Tu n'as été assigné à aucune équipe. Tu es désormais spectateur");
            }
        }

        //Scoreboard par joueur
        for(Player player : getServer().getOnlinePlayers()) {
            Scoreboard pBoard = Bukkit.getScoreboardManager().getNewScoreboard();
            Objective pObj = pBoard.registerNewObjective("pStats", "dummy");

            if(player.getGameMode() != GameMode.SPECTATOR) {
                pObj.setDisplayName(ChatColor.AQUA + "" + ChatColor.BOLD + player.getDisplayName());
                pObj.setDisplaySlot(DisplaySlot.SIDEBAR);
                player.setScoreboard(pBoard);
                //Ajouter dans le scoreboard de chaque joueur les équipes
                Team teamCT = pBoard.registerNewTeam("1");
                Team teamT = pBoard.registerNewTeam("2");
                for (OfflinePlayer CTplayer : mainBoard.getTeam("1").getPlayers()) {
                    teamCT.addPlayer(CTplayer);
                }
                for (OfflinePlayer Tplayer : mainBoard.getTeam("2").getPlayers()) {
                    teamT.addPlayer(Tplayer);
                }
                teamCT.setNameTagVisibility(NameTagVisibility.HIDE_FOR_OTHER_TEAMS);
                teamT.setNameTagVisibility(NameTagVisibility.HIDE_FOR_OTHER_TEAMS);

                //Argent
                setPlayerMoney(player, 800);
                setPlayerKills(player, 0);
                setPlayerDeaths(player, 0);
                player.addPotionEffect(new PotionEffect(PotionEffectType.SPEED, Integer.MAX_VALUE, 1));
                player.removePotionEffect(PotionEffectType.SPEED);
                player.setLevel(0);
                player.setExp(0);
                player.setGameMode(GameMode.SURVIVAL);
            }
        }
        //Bombe
        setValue("Bombe", 0);
        //Rounds
        setValue("TotRound", 0);
        //CTRound
        setValue("CTRound", 0);
        //TRound
        setValue("TRound", 0);

        OfflinePlayer op1 = Bukkit.getOfflinePlayer("1");
        mainBoard.getTeam("Started").addPlayer(op1);
        OfflinePlayer op2 = Bukkit.getOfflinePlayer("2");
        mainBoard.getTeam("Started").addPlayer(op2);
        TimerRound();
        OnRoundStart();
    }

    //OnStop
    public static void OnGameEnd(Team winner) {
        String teamName = winner.getDisplayName();
        sendMessage(ChatColor.DARK_GREEN + "      Les " + teamName + " ont gagnés la partie");
        sendMessage(ChatColor.DARK_AQUA + "Ils remportent 2 GoldCoins à dépenser sur la boutique");
        
        for(OfflinePlayer tM : winner.getPlayers()) {
            Player player = (Player) tM;
            getServer().dispatchCommand(getConsoleSender(), "coins " + player.getName() + " 2");
            Ranks.addWin(player);
        }

        //Donner l'ELO
        Scoreboard mainBoard = Bukkit.getScoreboardManager().getMainScoreboard();
        for(Player online : getServer().getOnlinePlayers()) {
            if(mainBoard.getPlayerTeam(online).getName().equals(mainBoard.getTeam("1").getName())
                    || mainBoard.getPlayerTeam(online).getName().equals(mainBoard.getTeam("2").getName())) {

                int elo = 0;
                //Win
                if (mainBoard.getPlayerTeam(online).getName().equals(winner.getName())) elo = elo + 30;
                else elo = elo - 15;
                //Kills
                int kills = getPlayerKills(online);
                elo = elo + (kills * 10);
                //Deaths
                int deaths = getPlayerDeaths(online);
                elo = elo + (deaths * (-5));
                //Bombe
                int bomb = getPlayerBomb(online);
                int earned_elo = elo;
                elo = elo + (bomb * 5);
                int old_elo = Ranks.getElo(online);
                elo = old_elo + elo;
                if(elo < 0) elo = 0;
                int old_rank = Ranks.getRankID(old_elo);
                Ranks.setElo(online, elo);
                int new_rank = Ranks.getRankID(elo);

                if(online.hasPermission("GR.vip")) {
                    online.sendMessage(ChatColor.DARK_AQUA + "Tu as actuellement " + elo + " points ELO");
                    online.sendMessage(ChatColor.DARK_AQUA + "Tu as remporté " + earned_elo + " points ELO durant cette partie");
                }
                else online.sendMessage(ChatColor.DARK_AQUA + "Devient VIP pour connaitre tes points ELO(plus d'informations sur le site http://goldrushmc.fr)");

                int wins = Ranks.getWin(online);
                if(wins < 5) online.sendMessage(ChatColor.DARK_AQUA + "Tu dois encore remporté " + ChatColor.AQUA + (5 - wins) + ChatColor.DARK_AQUA + " matchs pour afficher ton grade");
                else if(new_rank > old_rank) {
                    online.sendMessage(ChatColor.DARK_AQUA + "Tu as été promu " + ChatColor.AQUA + Ranks.getRankName(new_rank));
                    sendMessage(ChatColor.DARK_PURPLE + online.getName() + ChatColor.GRAY + " a été promu " + ChatColor.LIGHT_PURPLE + Ranks.getRankName(new_rank));
                }
                else if(new_rank < old_rank) online.sendMessage(ChatColor.DARK_AQUA + "Tu as été rétrogradé " + ChatColor.AQUA + Ranks.getRankName(online));
                else online.sendMessage(ChatColor.DARK_AQUA + "Ton grade actuel est " + ChatColor.AQUA + Ranks.getRankName(online));
            }
        }

        //Restart la partie
        getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
            @Override
            public void run() {
                getServer().dispatchCommand(getConsoleSender(), "status 3");
                getServer().dispatchCommand(getConsoleSender(), "sendplayer all Hub_1");
                getServer().dispatchCommand(getConsoleSender(), "reload");
            }
        }, 200L);
    }

    //OnRoundStart
    public static void OnRoundStart() {
        final Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();

        TimerRoundStart();
        setValue("TotRound", getValue("TotRound") + 1);
        //Reset la bombe
        Weapons.bombRemove();
        setValue("Bombe", 0);

        //Mettre les joueurs à la bonne position et mettre le timer pour le temps d'achat
        int CTposX = config.getInt("1.Spawn.posX");
        int CTposY = config.getInt("1.Spawn.posY");
        int CTposZ = config.getInt("1.Spawn.posZ");
        int TposX = config.getInt("2.Spawn.posX");
        int TposY = config.getInt("2.Spawn.posY");
        int TposZ = config.getInt("2.Spawn.posZ");
        Location CTspawn = null;
        Location Tspawn;

        int c = 1;
        //Spawn des CT
        for(OfflinePlayer CTOfflinePlayer : mainBoard.getTeam("1").getPlayers()) {
            Player CTplayer = (Player) CTOfflinePlayer;
            if(c == 1) {
                CTspawn = new Location(getOverWorld(), CTposX, CTposY, CTposZ);
            }
            else if(c == 2) {
                CTspawn = new Location(getOverWorld(), CTposX, CTposY, CTposZ + 4);
            }
            else if(c == 3) {
                CTspawn = new Location(getOverWorld(), CTposX, CTposY, CTposZ + 8);
            }
            else if(c == 4) {
                CTspawn = new Location(getOverWorld(), CTposX - 4, CTposY, CTposZ + 2);
            }
            else if(c >= 5) {
                CTspawn = new Location(getOverWorld(), CTposX - 4, CTposY, CTposZ + 6);
            }
            c++;
            //Donner les armes
            if(Weapons.getSecondary(CTplayer) == null) {
                weaponsInventory(CTplayer, null, "USP-S", false, true);
            }
            Weapons.refillAmmo(CTplayer);

            CTplayer.setGameMode(GameMode.SURVIVAL);
            CTplayer.setMaxHealth(20.0);
            CTplayer.setHealth(20.0);
            CTplayer.teleport(CTspawn);
        }

        mainBoard.getObjective("GameStats").getScore("buyable").setScore(1);

        c = 0;

        for(OfflinePlayer TOfflinePlayer : mainBoard.getTeam("2").getPlayers()) {
            Player Tplayer = (Player) TOfflinePlayer;
            Tspawn = new Location(getOverWorld(), TposX, TposY, TposZ + c);
            c = c + 4;
            if(Weapons.getSecondary(Tplayer) == null) {
                weaponsInventory(Tplayer, null, "GLOCK-18", true, false);
            }
            Weapons.refillAmmo(Tplayer);
            Tplayer.setGameMode(GameMode.SURVIVAL);
            Tplayer.setMaxHealth(20.0);
            Tplayer.setHealth(20.0);
            Tplayer.teleport(Tspawn);
        }

        getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
            @Override
            public void run() {
                OfflinePlayer op = Bukkit.getOfflinePlayer("3");
                mainBoard.getTeam("Started").addPlayer(op);
            }
        }, 200L);
    }

    //OnRoundEnd
    public static void OnRoundEnd(Team looser) {
        final Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
        Team winner;
        if(looser.getName().equals(mainBoard.getTeam("1").getName())) {
            winner = mainBoard.getTeam("2");
        } else {
            winner = mainBoard.getTeam("1");
        }

        Weapons.bombRemove();
        //Arreter le timer de l'explosion de la bombe
        getServer().getScheduler().cancelTask(mainBoard.getObjective("GameStats").getScore("bombTid").getScore());
        getServer().getScheduler().cancelTask(mainBoard.getObjective("GameStats").getScore("bombTid").getScore());
        String teamName = winner.getName();
        Sound soundWin;
        if(teamName.equals("1")) {     //Les CT perdent
            setValue("CTRound", getValue("CTRound") + 1);
            //CTwin
            soundWin = Sound.BAT_DEATH;
            sendMessage(ChatColor.BLUE + "Les anti-terroristes remportent la victoire");

        } else {    //Les T perdent
            sendMessage(ChatColor.GOLD + "Les terroristes remportent la victoire");
            //T win
            soundWin = Sound.BAT_IDLE;
            //On ajoute un round aux T
            setValue("TRound", getValue("TRound") + 1);
        }

        //Reset le timer
        int minutes = mainBoard.getObjective("GameStats").getScore("minutes").getScore();
        int secondes = mainBoard.getObjective("GameStats").getScore("secondes").getScore();
        String time;
        if(secondes < 10) time = ChatColor.AQUA + "" + minutes + ":" + "0" + secondes;
        else time = ChatColor.AQUA + "" + minutes + ":" + secondes;

        for (Player player : getServer().getOnlinePlayers()) {
            Scoreboard board = player.getScoreboard();
            player.playSound(player.getLocation(), soundWin, 1, 1);
            if(!mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Spectator").getName())) {
                board.resetScores(time);
            }
        }

        //Donne l'argent à chacun
        int CTmoney = 0;
        int Tmoney = 0;
        if(getValue("Bombe") == 1) Tmoney = Tmoney + 300;
        if(teamName.contains("Anti")) {
            CTmoney = CTmoney + 1400;
            Tmoney = Tmoney + 3600;
        }
        else {
            Tmoney = Tmoney + 1400;
            CTmoney = CTmoney + 3600;
        }

        for (OfflinePlayer CT : mainBoard.getTeam("1").getPlayers()) {
            Player CTplayer = (Player) CT;
            setPlayerMoney(CTplayer, getPlayerMoney(CTplayer) + CTmoney);
        }

        for (OfflinePlayer T : mainBoard.getTeam("2").getPlayers()) {
            Player Tplayer = (Player) T;
            setPlayerMoney(Tplayer, getPlayerMoney(Tplayer) + Tmoney);
        }

        OfflinePlayer op3 = Bukkit.getOfflinePlayer("3");
        mainBoard.getTeam("Started").removePlayer(op3);
        OfflinePlayer op2 = Bukkit.getOfflinePlayer("2");
        mainBoard.getTeam("Started").removePlayer(op2);

        if(getValue("TRound") == 8) {
            //Les terro ont gagné
            Team team = mainBoard.getTeam("2");
            OnGameEnd(team);
        }
        else if(getValue("CTRound") == 8) {
            //Les CT ont gagnés
            Team team = mainBoard.getTeam("1");
            OnGameEnd(team);
        }
        else {
            getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
                @Override
                public void run() {
                    OfflinePlayer op = Bukkit.getOfflinePlayer("2");
                    mainBoard.getTeam("Started").addPlayer(op);
                    OnRoundStart();
                }
            }, 100L);
        }
    }

    public static void reloadExp(final Player player, double reloadTime) {
        player.setExp(1);
        final int taskid = getServer().getScheduler().scheduleSyncRepeatingTask(plugin, new Runnable() {
            public void run() {
                player.setExp(player.getExp() - 0.05F);
            }
        }, (long)reloadTime, (long)reloadTime);

        getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
            @Override
            public void run() {
                Bukkit.getScheduler().cancelTask(taskid);
                player.setExp(0);
                player.setLevel(0);
            }
        }, (long)reloadTime * 20);
    }

    public static void OnDeath(Player killer, Player player) {

        if(killer != null) {
            String weaponName = ChatColor.stripColor(killer.getItemInHand().getItemMeta().getDisplayName());
            sendMessage(ChatColor.AQUA + "" + player.getDisplayName() + " a été tué par " + killer.getDisplayName() + " (" + weaponName + ")");
            //Ajoute le kill/mort à chaque joueur
            setPlayerKills(killer, getPlayerKills(killer) + 1);
            setPlayerDeaths(player, getPlayerDeaths(player) + 1);
            //Donne l'argent au tueur
            setPlayerMoney(killer, getPlayerMoney(killer) + 300);
        } else sendMessage(ChatColor.AQUA + "" + player.getDisplayName() + " s'est suicidé");

        //Annuler la mort
        player.setHealth(20.0);
        player.setGameMode(GameMode.SPECTATOR);
        player.getInventory().clear();

        //Drop la bombe
        ItemStack itemOnSlot = player.getInventory().getItem(5);
        if(itemOnSlot != null) {
            if (itemOnSlot.getType() == Material.OBSIDIAN) {
                getOverWorld().dropItem(player.getLocation(), itemOnSlot);
            }
        }

        //Vérifie s'il y a encore des survivants dans l'équipe
        Scoreboard mainBoard = Bukkit.getScoreboardManager().getMainScoreboard();
        Team team = mainBoard.getPlayerTeam(player);
        int sizeTeam = team.getSize();
        int deadMember = 0;
        for(OfflinePlayer tM : team.getPlayers()) {
            Player teamMember = (Player) tM;
            if(teamMember.getGameMode() == GameMode.SPECTATOR) {
                deadMember++;
            }
        }
        //Si tout le monde est mort dans l'équipe du tué
        if(sizeTeam <= deadMember) {
            if(getValue("Bombe") == 1) {
                //Si le tueur est un T
                if(mainBoard.getPlayerTeam(killer).getName().equals(mainBoard.getTeam("2").getName())) {
                    OnRoundEnd(mainBoard.getPlayerTeam(player));
                }
                else sendMessage(ChatColor.GREEN + "Tous les terroristes sont morts. Les anti-terroristes doivent maintenant désamorçer la bombe");
            }
            else {
                OnRoundEnd(mainBoard.getPlayerTeam(player));
            }
        }
    }

    public static void weaponsInventory(Player player, String primary, String secondary, boolean C4, boolean kit) {
        player.getInventory().clear();
        ItemStack ISprimary;
        ItemStack ISsecondary;
        int primary_ammo;
        int primary_mag;
        int secondary_ammo;
        int secondary_mag;

        //Initialisation des ItemStack en fonction de l'arme choisie
        ISprimary = new ItemStack(Weapons.getMaterial(primary), 1);
        ISsecondary = new ItemStack(Weapons.getMaterial(secondary), 1);
        primary_mag = Weapons.getAmmoInMagazine(primary);
        primary_ammo = Weapons.getAmmoInPocket(primary);
        secondary_mag = Weapons.getAmmoInMagazine(secondary);
        secondary_ammo = Weapons.getAmmoInPocket(secondary);

        if(primary != null) {
            ISprimary = setName(ISprimary, ChatColor.DARK_BLUE + primary, null);

            ItemStack ISprim_mag = new ItemStack(Material.GLOWSTONE_DUST, primary_mag);
            ISprim_mag = setName(ISprim_mag, ChatColor.RED + "Munitions(arme principale)", null);

            ItemStack ISprim_ammo = new ItemStack(Material.GLOWSTONE_DUST, primary_ammo);
            ISprim_ammo = setName(ISprim_ammo, ChatColor.RED + "Munitions(arme principale)", null);

            player.getInventory().setItem(0, ISprimary);
            player.getInventory().setItem(1, ISprim_mag);
            player.getInventory().setItem(7, ISprim_ammo);
        }
        if(secondary != null) {
            ISsecondary = setName(ISsecondary, ChatColor.DARK_BLUE + secondary, null);

            ItemStack ISsec_mag = new ItemStack(Material.DEAD_BUSH, secondary_mag);
            ISsec_mag = setName(ISsec_mag, ChatColor.RED + "Munitions(arme secondaire)", null);

            ItemStack ISsec_ammo = new ItemStack(Material.DEAD_BUSH, secondary_ammo);
            ISsec_ammo = setName(ISsec_ammo, ChatColor.RED + "Munitions(arme secondaire)", null);

            player.getInventory().setItem(2, ISsecondary);
            player.getInventory().setItem(3, ISsec_mag);
            player.getInventory().setItem(8, ISsec_ammo);

        }
        ItemStack IScut = new ItemStack(Material.WOOD_SWORD);
        IScut = setName(IScut, ChatColor.GOLD + "Couteau", null);
        player.getInventory().setItem(4, IScut);

        if(C4) {
            ItemStack ISc4 = new ItemStack(Material.OBSIDIAN);
            ISc4 = setName(ISc4, ChatColor.GOLD + "C4", null);
            player.getInventory().setItem(5, ISc4);
        }

        if(kit) {
            ItemStack ISkit = new ItemStack(Material.WOOD_PICKAXE);
            ISkit = setName(ISkit, ChatColor.GOLD + "Désamorçage", null);
            player.getInventory().setItem(5, ISkit);
        }

        ItemStack ISshop = new ItemStack(Material.REDSTONE_COMPARATOR);
        ISshop = setName(ISshop, ChatColor.DARK_AQUA + "Boutique", null);
        player.getInventory().setItem(6, ISshop);
    }

    public static void TimerLobby() {
        final int[] time = {config.getInt("LobbyTime") * 60};
        final Scoreboard mainBoard = Bukkit.getServer().getScoreboardManager().getMainScoreboard();
        final Objective obj = mainBoard.getObjective("GameStats");
        obj.getScore("secLobby").setScore(time[0]);
        final int[] rule = {6};

        final int timerid = getServer().getScheduler().scheduleSyncRepeatingTask(plugin, new Runnable() {
            public void run() { //Timer du Lobby
                time[0] = obj.getScore("secLobby").getScore();
                time[0]--;
                for (Player online : getServer().getOnlinePlayers()) {
                    online.setLevel(time[0]);
                }

                //Commence la partie si il y a assez de joueurs
                if (time[0] == 0) {
                    int players = getServer().getOnlinePlayers().size();
                    if (players < config.getInt("MinPlayers")) {
                        time[0] = config.getInt("LobbyTime") * 60;
                        sendMessage(ChatColor.RED + "Il n'y a pas assez de joueurs pour commencer la partie (" + config.getInt("MinPlayers") + " mininum)");
                    } else {
                        //La partie démarre
                        for (Player online : getServer().getOnlinePlayers()) {
                            online.setLevel(0);
                            online.setExp(0.0F);
                        }
                        //Arrête le timer
                        int timerID = obj.getScore("timerLobbyID").getScore();
                        getServer().getScheduler().cancelTask(timerID);
                        OnGameStart();
                        return;
                    }
                }

                //Réduit le temps d'attente si il y a assez de joueurs
                if(getServer().getOnlinePlayers().size() >= config.getInt("MinPlayers") && time[0] > 40) {
                    time[0] = 40;
                }

                //Emmet un son si la partie commence dans moins de 10 secondes
                if(time[0] <= 10) {
                    for(Player online : getServer().getOnlinePlayers()) {
                        online.playSound(online.getLocation(), Sound.NOTE_PIANO, 1, 1);
                    }
                }
                rule[0]++;
                if(rule[0] == 10) {
                    rule[0] = 0;
                    sendMessage("");
                    sendMessage(ChatColor.LIGHT_PURPLE+ randomRule());
                }

                obj.getScore("secLobby").setScore(time[0]);
            }
        }, 20L, 20L);

        //Enregistre l'id du timerLobby dans le scoreboard
        obj.getScore("timerLobbyID").setScore(timerid);
    }

    public static void TimerRoundStart() {
        final int[] time = {10};

        final int timerid = getServer().getScheduler().scheduleSyncRepeatingTask(plugin, new Runnable() {
            public void run() { //Timer du Lobby
                time[0]--;
                for (Player online : getServer().getOnlinePlayers()) {
                    online.setLevel(time[0]);
                }
                if (time[0] == 0) {
                    for (Player online : getServer().getOnlinePlayers()) {
                        online.setLevel(0);
                        online.setExp(0.0F);
                    }
                    return;
                }
            }
        }, 20L, 20L);

        getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
            @Override
            public void run() {
                time[0] = config.getInt("LobbyTime") * 60 / 20;
                for (Player online : getServer().getOnlinePlayers()) {
                    online.setLevel(0);
                    online.setExp(0.0F);
                }
                int players = getServer().getOnlinePlayers().size();
                if (players < config.getInt("MinPlayers")) {
                    TimerLobby();
                }
                getServer().getScheduler().cancelTask(timerid);
            }
        }, (long)time[0] * 21);
    }

    public static void TimerRound() {
        final Scoreboard mainBoard = getServer().getScoreboardManager().getMainScoreboard();

        final Objective mainObj = mainBoard.getObjective("GameStats");
        final int[] minutes = {2};
        final int[] secondes = {1};

        final int timerRound = getServer().getScheduler().scheduleSyncRepeatingTask(plugin, new Runnable() {
            public void run() { //Timer du Round

                secondes[0] = mainObj.getScore("sec").getScore();
                minutes[0] = mainObj.getScore("min").getScore();
                for (Player player : getServer().getOnlinePlayers()) {
                    Scoreboard board = player.getScoreboard();
                    if (!mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Spectator").getName())) {
                        if (secondes[0] < 10) {
                            board.resetScores(ChatColor.AQUA + "" + minutes[0] + ":0" + secondes[0]);
                        } else {
                            board.resetScores(ChatColor.AQUA + "" + minutes[0] + ":" + secondes[0]);
                        }
                    }
                }
                if(GameStatus() == 3) {
                    if (secondes[0] <= 0) {
                        secondes[0] = 60;
                        minutes[0]--;
                    }
                    if (getValue("Bombe") == 0) {
                        secondes[0]--;
                    }
                    if (secondes[0] == 40 && minutes[0] == 1) {
                        mainBoard.getObjective("GameStats").getScore("buyable").setScore(0);
                        Shop.closeShops();
                    }

                    if (minutes[0] <= 0 && secondes[0] <= 0) {
                        OnRoundEnd(mainBoard.getTeam("2"));
                    }

                    for (Player player : getServer().getOnlinePlayers()) {
                        if (!mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Spectator").getName())) {
                            Scoreboard board = player.getScoreboard();
                            Objective objective = board.getObjective("pStats");
                            if (secondes[0] < 10) {
                                objective.getScore(Bukkit.getOfflinePlayer(ChatColor.AQUA + "" + minutes[0] + ":0" + secondes[0])).setScore(6);
                            } else {
                                objective.getScore(Bukkit.getOfflinePlayer(ChatColor.AQUA + "" + minutes[0] + ":" + secondes[0])).setScore(6);
                            }
                        }
                    }
                }
                else {
                    minutes[0] = 2;
                    secondes[0] = 1;
                }
                mainObj.getScore("sec").setScore(secondes[0]);
                mainObj.getScore("min").setScore(minutes[0]);
            }
        }, 20L, 20L);
    }

    public static void setValue(String strObj, int score) {
        final Scoreboard mainBoard = getServer().getScoreboardManager().getMainScoreboard();

        //Update le scoreboard
        for(Player player : getServer().getOnlinePlayers()) {
            if (!mainBoard.getPlayerTeam(player).getName().equals(mainBoard.getTeam("Spectator").getName())) {
                Scoreboard board = player.getScoreboard();
                Objective pObj = board.getObjective("pStats");
                String PlayerString = null;
                String newPlayerString = null;
                int scoreLevel = 0;

                if (strObj.equals("CTRound")) {
                    PlayerString = ChatColor.BLUE + config.getString("1.Nom") + " : " + getValue("CTRound") + "/8";
                    newPlayerString = ChatColor.BLUE + config.getString("1.Nom") + " : " + score + "/8";
                    scoreLevel = 3;
                } else if (strObj.equals("TRound")) {
                    PlayerString = ChatColor.GOLD + config.getString("2.Nom") + " : " + getValue("TRound") + "/8";
                    newPlayerString = ChatColor.GOLD + config.getString("2.Nom") + " : " + score + "/8";
                    scoreLevel = 2;
                } else if (strObj.equals("TotRound")) {
                    PlayerString = ChatColor.AQUA + "Round " + getValue("TotRound") + "/15";
                    newPlayerString = ChatColor.AQUA + "Round " + score + "/15";
                    scoreLevel = 4;
                } else if (strObj.equals("Bombe")) {
                    if (score == 1) {
                        PlayerString = ChatColor.GREEN + "Bombe non posée";
                        newPlayerString = ChatColor.DARK_RED + "" + ChatColor.BOLD + "Bombe posée";
                    } else {
                        PlayerString = ChatColor.DARK_RED + "" + ChatColor.BOLD + "Bombe posée";
                        newPlayerString = ChatColor.GREEN + "Bombe non posée";
                    }
                    scoreLevel = 5;
                }

                board.resetScores(PlayerString);
                pObj.getScore(newPlayerString).setScore(scoreLevel);
            }
        }

        Objective obj = mainBoard.getObjective("GameStats");
        obj.getScore(strObj).setScore(score);
    }

    public static int getValue(String strObj) {
        final Scoreboard mainBoard = getServer().getScoreboardManager().getMainScoreboard();
        Objective obj = mainBoard.getObjective("GameStats");
        int score = obj.getScore(strObj).getScore();
        return score;
    }

    public static void setPlayerMoney(Player player, int money) {
        Scoreboard board = player.getScoreboard();
        Objective playerObj = board.getObjective("pStats");
        Objective mainObj = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        if(money > 16000) money = 16000;
        //Supprimer l'ancien
        board.resetScores(ChatColor.AQUA + "Argent : " + getPlayerMoney(player) + "$");
        //Nouvel affichage
        playerObj.getScore(ChatColor.AQUA + "Argent : " + money + "$").setScore(1);
        mainObj.getScore("m" + player.getName()).setScore(money);
    }

    public static int getPlayerMoney(Player player) {
        Objective objective = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        int money = objective.getScore("m" + player.getName()).getScore();
        return money;
    }

    public static void setPlayerKills(Player player, int kills) {
        Scoreboard board = player.getScoreboard();
        Objective playerObj = board.getObjective("pStats");
        Objective mainObj = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        //Supprimer l'ancien
        board.resetScores(ChatColor.AQUA + "Kills : " + getPlayerKills(player));
        //Nouvel affichage
        playerObj.getScore(ChatColor.AQUA + "Kills : " + kills).setScore(-1);
        mainObj.getScore("k" + player.getName()).setScore(kills);
    }

    public static int getPlayerKills(Player player) {
        Objective objective = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        int money = objective.getScore("k" + player.getName()).getScore();
        return money;
    }

    public static void setPlayerDeaths(Player player, int deaths) {
        Scoreboard board = player.getScoreboard();
        Objective playerObj = board.getObjective("pStats");
        Objective mainObj = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        //Supprimer l'ancien
        board.resetScores(ChatColor.AQUA + "Morts : " + getPlayerDeaths(player));
        //Nouvel affichage
        playerObj.getScore(ChatColor.AQUA + "Morts : " + deaths).setScore(-2);
        mainObj.getScore("d" + player.getName()).setScore(deaths);
    }

    public static int getPlayerDeaths(Player player) {
        Objective objective = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        int money = objective.getScore("d" + player.getName()).getScore();
        return money;
    }

    public static void setPlayerBomb(Player player, int bomb) {
        Scoreboard board = player.getScoreboard();
        Objective mainObj = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        mainObj.getScore("b" + player.getName()).setScore(bomb);
    }

    public static int getPlayerBomb(Player player) {
        Objective objective = getScoreboardManager().getMainScoreboard().getObjective("GameStats");
        int money = objective.getScore("b" + player.getName()).getScore();
        return money;
    }

    public static void playDamage(Player player, double damage) {
        getOverWorld().playSound(player.getLocation(), Sound.HURT_FLESH, 20, 1);
        player.setHealth(player.getHealth() - damage);
        getOverWorld().playEffect(player.getLocation(), Effect.STEP_SOUND, Material.REDSTONE_BLOCK);
    }

    public static void playerShoot(final Player player) {
        ItemStack currentItem = player.getItemInHand();
        if(currentItem == null) return;

        //10 secondes avant l'achat
        if(GameStatus() != 3) return;

        //Si le joueur est déjà en train de tirer
        if(player.getInventory().getItem(17) != null) return;

        //Si le joueur recharge
        if(player.getExp() > 0.05) return;

        //Regarde le type d'arme(main, secondaire, couteau)
        int weaponType = player.getInventory().getHeldItemSlot();

        Player target = getTargetPlayer(player);

        //Couteau en main clic gauche
        if(weaponType == 4) {
            if(target == null) return;
            if(target.getLocation().distance(player.getLocation()) <= 1.5) {
                if (!sameTeams(player, target)) {
                    double damage = 4.0;
                    if (damage >= target.getHealth()) {
                        OnDeath(player, target);
                    }
                    getOverWorld().playSound(player.getLocation(), Sound.CAT_HISS, 50, 1);
                    playDamage(target, damage);
                    return;
                }
            }
        }

        if(weaponType != 0 && weaponType != 2) return;

        //Munitions
        ItemStack ISammo;
        //Principale
        if(weaponType == 0) {
            ISammo = player.getInventory().getItem(1);
        }
        //Secondaire
        else if(weaponType == 2) {
            ISammo = player.getInventory().getItem(3);
        }
        //S'il n'y a plus de munitions
        else return;
        if(ISammo == null) return;
        if (ISammo.getType() == Material.MILK_BUCKET) {
            getOverWorld().playSound(player.getLocation(), Sound.CLICK, 15, 1);
            return;
        }
        //-1 aux munitions
        int ammo = ISammo.getAmount();
        ISammo.setAmount(ISammo.getAmount() - 1);
        //Mettre les items à 0 s'il n'y a plus de munitions
        if(ammo <= 1) {
            ItemStack ISbucket = new ItemStack(Material.MILK_BUCKET);
            ISbucket = setName(ISbucket, ChatColor.RED + "Plus de munitions", null);
            player.getInventory().setItem(weaponType + 1, ISbucket);
        }

        getOverWorld().playSound(player.getLocation(), Sound.CHICKEN_EGG_POP, 100, 1);

        Material itemInHand;
        try {
            itemInHand = player.getItemInHand().getType();
        } catch (Exception ex) {return;}

        //Lancez un timer pour limiter la cadence de tir
        player.getInventory().setItem(17, new ItemStack(Material.WOOD, 1));
        getServer().getScheduler().scheduleSyncDelayedTask(plugin, new Runnable() {
            @Override
            public void run() {
                player.getInventory().clear(17);
            }
        }, Weapons.getFireInterval(itemInHand));

        if(target == null) return;

        if(target.getGameMode() != GameMode.SURVIVAL) return;

        //Précision

        double damage = Weapons.getDamage(itemInHand) * 2;
        double hurtLevel = Weapons.getHurtLevel(itemInHand);

        //Dommages en fonction de la distance
        double distance = player.getLocation().distance(target.getLocation());
        int damage_distance = Weapons.getDamageDistance(itemInHand);
        double multi = distance / damage_distance;
        double surplus = (multi - 1) / damage_distance;
        damage = damage * (1 - surplus);

        //Sneak 100%
        if(player.isSneaking()) {
            hurtLevel = 100;
        }
        //Sprint /2
        else if(player.isSprinting()) {
            hurtLevel = hurtLevel / 2;
        }
        //Courre sans sprinter /2
        else if(!player.isSneaking() && !player.isSprinting()) {
            hurtLevel = hurtLevel / 1.25;
        }
        //Debout -5
        else {
            hurtLevel = hurtLevel - 3;
        }

        int randomNum = randomInt(0, 100);
        if(randomNum > hurtLevel || target == null) return;

        //Si il meurt
        if(damage >= target.getHealth()) {
            OnDeath(player, target);
        }
        else {
            playDamage(target, damage);
        }
    }
}
