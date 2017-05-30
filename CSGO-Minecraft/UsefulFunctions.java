package fr.goldrush.ostralopitek.gungr;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.World;
import org.bukkit.block.Block;
import org.bukkit.entity.Entity;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.plugin.Plugin;
import org.bukkit.scoreboard.Scoreboard;
import org.bukkit.scoreboard.Team;
import org.bukkit.util.BlockIterator;
import org.bukkit.util.Vector;

import java.util.List;
import java.util.Random;

import static org.bukkit.Bukkit.getPluginManager;
import static org.bukkit.Bukkit.getServer;

public class UsefulFunctions {

    static Plugin plugin = getPluginManager().getPlugin("GunGR");

    public static Player getTargetPlayer(final Player player) {
        return getTarget(player, player.getWorld().getPlayers());
    }

    public static <T extends Entity> T getTarget(final Entity entity,
                                                 final Iterable<T> entities) {
        if (entity == null)
            return null;
        T target = null;
        final double threshold = 1;
        for (final T other : entities) {
            final Vector n = other.getLocation().toVector()
                    .subtract(entity.getLocation().toVector());
            if (entity.getLocation().getDirection().normalize().crossProduct(n)
                    .lengthSquared() < threshold
                    && n.normalize().dot(
                    entity.getLocation().getDirection().normalize()) >= 0) {
                if (target == null
                        || target.getLocation().distanceSquared(
                        entity.getLocation()) > other.getLocation()
                        .distanceSquared(entity.getLocation()))
                    target = other;
            }
        }
        return target;
    }

    public static Block getTargetBlock(Player player, Integer range) {
        BlockIterator bi= new BlockIterator(player, range);
        Block lastBlock = bi.next();
        while (bi.hasNext()) {
            lastBlock = bi.next();
            if (lastBlock.getType() == Material.AIR)
                continue;
            break;
        }
        return lastBlock;
    }

    public static int randomInt(int min, int max) {
        Random rand = new Random();
        int randomNum = rand.nextInt((max - min) + 1) + min;
        return randomNum;
    }

    public static boolean sameTeams(Player player1, Player player2) {
        Scoreboard board = Bukkit.getScoreboardManager().getMainScoreboard();
        if(player1 == null || player2 == null) return false;
        Team team1 = null;
        Team team2 = null;
        try {
            team1 = board.getPlayerTeam(player1);
        } catch (Exception ex) {}
        try {
            team2 = board.getPlayerTeam(player2);
        } catch (Exception ex) {}

        if(team1.getName().equals(team2.getName())) return true;
        else return false;
    }

    public static int GameStatus() {
        Scoreboard board = Bukkit.getScoreboardManager().getMainScoreboard();
        int status = board.getTeam("Started").getSize();
        return status;
    }

    public static ItemStack setName(ItemStack is, String name, List<String> lore) {
        ItemMeta im = is.getItemMeta();
        if(name != null) {
            im.setDisplayName(name);
        }
        if (lore != null) {
            im.setLore(lore);
        }
        is.setItemMeta(im);
        return is;
    }

    public static World getOverWorld() {
        for (World world : getServer().getWorlds()) {
            return world;
        }
        World world = null;
        return world;
    }

    public static void sendMessage(String message) {
        for(Player online : getServer().getOnlinePlayers()) {
            online.sendMessage(message);
        }
    }

    public static String randomRule() {
        String rule = "";
        int randInt = randomInt(1, 15);
        if(randInt == 1) rule = "Le jeu est composé de deux équipes : Les terroristes qui doivent poser la bombe et les anti-terroristes qui doivent sécuriser les sites " +
                "de bombe A et B ou désamorcer la bombe si elle a été posée";
        else if(randInt == 2) rule = "Vous toucherez vos ennemis à 100% seulement si vous êtes en sneak";
        else if(randInt == 3) rule = "Vous devez utiliser le clic gauche pour tirer et drop votre arme au sol pour recharger";
        else if(randInt == 4) rule = "Moins vous bougez, Plus vous serez précis";
        else if(randInt == 5) rule = "La bombe doit être plantée sur les sites de bombes A et B représentés par les JukeBox";
        else if(randInt == 6) rule = "La bombe doit être désamorçée avec la pioche. Vous pouvez acheter un kit de désamorçage pour pouvoir désamorçer plus vite";
        else if(randInt == 7) rule = "La bombe explose au bout de 45 secondes";
        else if(randInt == 8) rule = "Il est fortement recommandé de lire le livre avant votre première partie";
        else if(randInt == 9) rule = "Vous devez acheter vos armes avec l'objet boutique";
        else if(randInt == 10) rule = "La barre d'exp vous indique si vous êtes en train de recharger";
        else if(randInt == 11) rule = "Certaines armes ont un délai important entre chaque tir(AWP, SSG...)";
        else if(randInt == 12) rule = "Si vous quittez une partie alors qu'elle n'est pas terminée vous serez sanctionnés d'un malus ELO(points utilisés pour votre classement)";
        else if(randInt == 13) rule = "Toutes les informations concernant le GunGR sont disponibles à l'adresse http://goldrushmc.fr/p/gungr";
        else if(randInt == 14) rule = "Lorsque vous êtes terroriste, vous devez casser les JukeBox au sol avec la bombe en main pour pouvoir la planter";
        else if(randInt == 15) rule = "Lorsque vous êtes anti-terroriste, vous devez casser le bloc de TNT placé sur le site avec votre outil de désamorçage en main pour pouvoir désamorçer la bombe";
        else if(randInt == 16) rule = "";
        else if(randInt == 17) rule = "";
        else if(randInt == 18) rule = "";
        else if(randInt == 19) rule = "";
        return rule;
    }
}