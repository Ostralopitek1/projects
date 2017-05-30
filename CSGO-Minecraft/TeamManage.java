package fr.goldrush.ostralopitek.gungr;

import org.bukkit.*;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.BookMeta;
import org.bukkit.plugin.Plugin;
import org.bukkit.scoreboard.Scoreboard;
import org.bukkit.scoreboard.Team;

import java.util.ArrayList;
import java.util.List;

import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.*;

import static org.bukkit.Bukkit.getPluginManager;
import static org.bukkit.Bukkit.getServer;

public class TeamManage {

    static Plugin plugin = getPluginManager().getPlugin("GunGR");
    public static Main main;
    static final FileConfiguration config = plugin.getConfig();

    //LUpdate
    public static void TeamItemsUpdate(Player player) {
        final Scoreboard board = Bukkit.getScoreboardManager().getMainScoreboard();
        String itemoncursor;

        try {
            itemoncursor = player.getItemInHand().getItemMeta().getDisplayName();
        } catch (Exception ex) {return;}

        int players = getServer().getOnlinePlayers().size();
        if(players <= 1) {
            player.sendMessage(ChatColor.RED + "Tu ne peux pas choisir d'équipe lorsque tu es seul");
            return;
        }
        int teamSize = players / 2;

        if (itemoncursor == null) return;
        //CT
        else if (itemoncursor.contains(config.getString("1.Nom"))) {
            Team team = board.getTeam("1");
            if(board.getPlayerTeam(player) != null) {
                if (team.getName().equals(board.getPlayerTeam(player).getName())) return;
            }
            if (team.getSize() >= teamSize) {
                player.sendMessage(ChatColor.RED + "Les anti-terroristes ont suffisament de joueurs");
                return;
            }
            team.addPlayer(player);
            player.setPlayerListName(ChatColor.BLUE + player.getDisplayName());
            player.sendMessage(ChatColor.BLUE + "Tu as rejoint les anti-terroristes");
        }
        //T
        else if (itemoncursor.contains(config.getString("2.Nom"))) {
            Team team = board.getTeam("2");
            if(board.getPlayerTeam(player) != null) {
                if (team.getName().equals(board.getPlayerTeam(player).getName())) return;
            }
            if (team.getSize() >= teamSize) {
                player.sendMessage(ChatColor.RED + "Les terroristes ont suffisament de joueurs");
                return;
            }
            team.addPlayer(player);
            player.setPlayerListName(ChatColor.GOLD + player.getDisplayName());
            player.sendMessage(ChatColor.GOLD + "Tu as rejoint les terroristes");
        }
        ItemsSet();
    }

    public static void ItemsSet() {
        final Scoreboard board = Bukkit.getScoreboardManager().getMainScoreboard();
        for (Player online : getServer().getOnlinePlayers()) {
            online.getInventory().clear();
            ItemStack itemstack = new ItemStack(Material.WOOL);
            itemstack.setAmount(1);
            List<String> ls = new ArrayList<String>();
            for(int i = 1; i <= 2; i++) {
                ls.clear();
                if(i == 1) {
                    for(OfflinePlayer member : board.getTeam("1").getPlayers()) {
                        String name = member.getPlayer().getDisplayName();
                        ls.add(name);
                    }
                    online.getInventory().addItem(setName(new ItemStack(Material.WOOL, 1, (byte)11), ChatColor.BLUE + "" + config.getString("1.Nom"), ls));
                } else if(i == 2) {
                    for(OfflinePlayer member : board.getTeam("2").getPlayers()) {
                        String name = member.getPlayer().getName();
                        ls.add(name);
                    }
                    online.getInventory().addItem(setName(new ItemStack(Material.WOOL, 1, (byte)1), ChatColor.GOLD + "" + config.getString("2.Nom"), ls));
                    giveRulesBookToPlayer(online);
                }
                online.updateInventory();
            }
        }
    }

    public static void giveRulesBookToPlayer(Player player) {
        // create a list of book pages (where each item is a String)
        List<String> pages = new ArrayList<String>();

        pages.add(ChatColor.DARK_RED + "Mécaniques de jeu : \n " +
                ChatColor.BLACK + "Toutes ces informations sont disponibles sur le site à l'adresse\n" +
                ChatColor.DARK_GREEN + "http://goldrushmc.fr/p/gungr\n" +
                ChatColor.BLACK + "-Le jeu a été fait à l'image du mode MatchMaking de CS:GO\n" +
                "-Le jeu est composé de deux équipes : Les terroristes qui doivent poser la bombe ");

        pages.add("et les anti-terroristes qui doivent sécuriser les sites " +
                "de bombe A et B ou désamorcer la bombe si elle a été posée\n" +
                "-Vous toucherez vos ennemis à 100% seulement si vous êtes en sneak.\n" +
                "-Moins vous bougez, Plus vous serez précis");

        pages.add("-La bombe doit être plantée sur les sites de bombes A et B représentés " +
                "par les blocs de sandstone à traits rouges.\n" +
                "-La bombe doit être désamorçée avec la pioche\n" +
                "-La bombe explose au bout de 45 secondes");

        pages.add("-Toute l'équipe des terroristes commence la manche avec la bombe.\n" +
                "-Les différentes positions sont disponibles sur le site à l'adresse indiquée sur la première page\n" +
                "-Vous gagnerez de l'argent à chaque kill et à la fin de chaque manche même en cas de défaite");

        pages.add("-Vous devez acheter vos armes avec l'objet boutique\n" +
                "-Vous devez racheter vos armes dès que vous mourrez\n" +
                "-Toutes les informations sont disponibles sur le scoreboard\n" +
                "qui se trouvera à droite de votre écran");

        pages.add(ChatColor.DARK_RED + "Fonctionnement des armes\n" +
                ChatColor.BLACK + "-Pour recharger votre arme vous devez utiliser la touche vous permettant\n" +
                "de lâcher les objets au sol(il est conseillé de l'assigner à la touche \"R\".\n" +
                "-La barre d'exp vous indique si vous êtes en train de recharger\n" +
                "-Certaines armes ont un délai important entre chaque tir(AWP, SSG...)");

        pages.add(ChatColor.DARK_RED + "Système de rangs\n" +
                ChatColor.BLACK + "-Les rangs sont les mêmes que ceux du MatchMaking CS:GO : Argent 1 à Global Elite\n" +
                "-Vous gagnerez ou perdrez des points(points ELO) à chaque partie\n" +
                "-Si vous quittez une partie alors qu'elle n'est pas terminée vous " +
                "serez sanctionnés d'un malus ELO");

        pages.add("-Vous ne pouvez voir votre nombre de points ELO que si vous êtes VIP");

        // create the book
        ItemStack book = new ItemStack(Material.WRITTEN_BOOK); // create new book item
        BookMeta bookData = (BookMeta) book.getItemMeta(); // create the data (title, author, etc)
        // to be added to the book

        bookData.setTitle(ChatColor.DARK_AQUA + "Règles GunGR"); // set book title
        bookData.setAuthor("Ostralopitek"); // set book author

        bookData.setPages(pages); // use the pages list for the book pages

        // use data in book
        book.setItemMeta(bookData);

        // give book to player
        player.getInventory().setItem(8, book);
    }
}
