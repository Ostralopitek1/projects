package fr.goldrush.ostralopitek.gungr;


import org.bukkit.Bukkit;
import org.bukkit.ChatColor;
import org.bukkit.Material;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.entity.Player;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.ItemStack;
import org.bukkit.scoreboard.Scoreboard;

import java.util.ArrayList;
import java.util.List;

import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.setName;
import static org.bukkit.Bukkit.getScoreboardManager;
import static org.bukkit.Bukkit.getServer;

public class Shop {

    static Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
    static FileConfiguration config = Bukkit.getPluginManager().getPlugin("GunGR").getConfig();

    public static void mainMenu(Player player) {
        player.closeInventory();
        Inventory inv = Bukkit.createInventory(null, 45, ChatColor.BLACK + "Boutique");
        /*
        PISTOLETS
         */
        ItemStack isP250 = new ItemStack(Material.getMaterial(config.getInt("Weapons.P250.ItemID")), 1);
        isP250 = setName(isP250, ChatColor.DARK_AQUA + "PISTOLETS", null);
        inv.setItem(3, isP250);

        /*
        LOURDES
         */
        ItemStack isNOVA = new ItemStack(Material.getMaterial(config.getInt("Weapons.NOVA.ItemID")), 1);
        isNOVA = setName(isNOVA, ChatColor.DARK_AQUA + "LOURDES", null);
        inv.setItem(5, isNOVA);

        /*
        PMs
         */
        ItemStack isP90 = new ItemStack(Material.getMaterial(config.getInt("Weapons.P90.ItemID")), 1);
        isP90 = setName(isP90, ChatColor.DARK_AQUA + "PMs", null);
        inv.setItem(24, isP90);

        /*
        Fusils
         */
        //M4 pour les CT
        if(mainBoard.getTeam("1").getName().contains(mainBoard.getPlayerTeam(player).getName())) {
            ItemStack isM4A1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.M4A1-S.ItemID")), 1);
            isM4A1 = setName(isM4A1, ChatColor.DARK_AQUA + "FUSILS", null);
            inv.setItem(41, isM4A1);
        }
        //AK pour les T
        else {
            //AK-47
            ItemStack isAK47 = new ItemStack(Material.getMaterial(config.getInt("Weapons.AK-47.ItemID")), 1);
            isAK47 = setName(isAK47, ChatColor.DARK_AQUA + "FUSILS", null);
            inv.setItem(41, isAK47);
        }

        /*
        Defuse kit
         */
        if(mainBoard.getTeam("1").getName().contains(mainBoard.getPlayerTeam(player).getName())) {
            ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.KIT.ItemID")), 1);
            is1 = setName(is1, ChatColor.DARK_AQUA + "Kit de désamorçage", null);
            inv.setItem(39, is1);
        }
        player.openInventory(inv);
    }

    public static void fusilsMenu(Player player) {
        player.closeInventory();
        Inventory inv = Bukkit.createInventory(null, 45, ChatColor.BLACK + "Fusils");

        List ls = new ArrayList<String>();
        /*
        FAMAS
         */
        ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.FAMAS.ItemID")), 1);
        ls.clear();
        ls.add(config.getInt("Weapons.FAMAS.Price") + " $");
        is1 = setName(is1, ChatColor.DARK_AQUA + "FAMAS", ls);
        inv.setItem(3, is1);

        /*
        M4A1-S et AK-47
         */
        if(mainBoard.getTeam("1").getName().contains(mainBoard.getPlayerTeam(player).getName())) {
            //M4A1-S
            ItemStack is2 = new ItemStack(Material.getMaterial(config.getInt("Weapons.M4A1-S.ItemID")), 1);
            ls.clear();
            ls.add(config.getInt("Weapons.M4A1-S.Price") + "$");
            is2 = setName(is2, ChatColor.DARK_AQUA + "M4A1-S", ls);
            inv.setItem(5, is2);
        }
        else {
            //AK
            ItemStack is2 = new ItemStack(Material.getMaterial(config.getInt("Weapons.AK-47.ItemID")), 1);
            ls.clear();
            ls.add(config.getInt("Weapons.AK-47.Price") + " $");
            is2 = setName(is2, ChatColor.DARK_AQUA + "AK-47", ls);
            inv.setItem(5, is2);
        }

        /*
        SSG 08
         */
        ItemStack is3 = new ItemStack(Material.getMaterial(config.getInt("Weapons.SSG_08.ItemID")), 1);
        ls.clear();
        ls.add(config.getInt("Weapons.SSG_08.Price") + " $");
        is3 = setName(is3, ChatColor.DARK_AQUA + "SSG_08", ls);
        inv.setItem(24, is3);

        /*
        AUG et SG
         */
        //AUG pour les CT
        if(mainBoard.getTeam("1").getName().contains(mainBoard.getPlayerTeam(player).getName())) {
            ItemStack is4 = new ItemStack(Material.getMaterial(config.getInt("Weapons.AUG.ItemID")), 1);
            ls.clear();
            ls.add(config.getInt("Weapons.AUG.Price") + " $");
            is4 = setName(is4, ChatColor.DARK_AQUA + "AUG", ls);
            inv.setItem(41, is4);
        }
        //SG 553 pour les T
        else {
            //SG 553
            ItemStack is4 = new ItemStack(Material.getMaterial(config.getInt("Weapons.SG_553.ItemID")), 1);
            ls.clear();
            ls.add(config.getInt("Weapons.SG_553.Price") +  " $");
            is4 = setName(is4, ChatColor.DARK_AQUA + "SG_553", ls);
            inv.setItem(41, is4);
        }

        /*
        AWP
         */
        ItemStack is5 = new ItemStack(Material.getMaterial(config.getInt("Weapons.AWP.ItemID")), 1);
        ls.clear();
        ls.add(config.getInt("Weapons.AWP.Price") +  " $");
        is5 = setName(is5, ChatColor.DARK_AQUA + "AWP", ls);
        inv.setItem(39, is5);

        /*
        Auto
         */
        ItemStack is6 = new ItemStack(Material.getMaterial(config.getInt("Weapons.AUTO.ItemID")), 1);
        ls.clear();
        ls.add(config.getInt("Weapons.AUTO.Price") +  " $");
        is6 = setName(is6, ChatColor.DARK_AQUA + "AUTO", ls);
        inv.setItem(20, is6);

        player.openInventory(inv);
    }

    public static void pmsMenu(Player player) {
        player.closeInventory();
        Inventory inv = Bukkit.createInventory(null, 45, ChatColor.BLACK + "Pistolets Mitrailleurs");

        /*
        MP9
         */
        ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.MP9.ItemID")), 1);
        is1 = setName(is1, ChatColor.DARK_AQUA + "MP9", null);
        inv.setItem(3, is1);

        /*
        MP7
         */
        ItemStack is2 = new ItemStack(Material.getMaterial(config.getInt("Weapons.MP7.ItemID")), 1);
        is2 = setName(is2, ChatColor.DARK_AQUA + "MP7", null);
        inv.setItem(5, is2);

        /*
        UMP-45
         */
        ItemStack is3 = new ItemStack(Material.getMaterial(config.getInt("Weapons.UMP-45.ItemID")), 1);
        is3 = setName(is3, ChatColor.DARK_AQUA + "UMP-45", null);
        inv.setItem(24, is3);

        /*
        P90
         */
        ItemStack is4 = new ItemStack(Material.getMaterial(config.getInt("Weapons.P90.ItemID")), 1);
        is4 = setName(is4, ChatColor.DARK_AQUA + "P90", null);
        inv.setItem(41, is4);

        /*
        PP-Bizon
         */
        ItemStack is5 = new ItemStack(Material.getMaterial(config.getInt("Weapons.PP-Bizon.ItemID")), 1);
        is5 = setName(is5, ChatColor.DARK_AQUA + "PP-Bizon", null);
        inv.setItem(39, is5);

        player.openInventory(inv);
    }

    public static void lourdesMenu(Player player) {
        player.closeInventory();
        Inventory inv = Bukkit.createInventory(null, 45, ChatColor.BLACK + "Lourdes");

        /*
        Nova
         */
        ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.Nova.ItemID")), 1);
        is1 = setName(is1, ChatColor.DARK_AQUA + "Nova", null);
        inv.setItem(3, is1);

        /*
        XM1014
         */
        ItemStack is2 = new ItemStack(Material.getMaterial(config.getInt("Weapons.XM1014.ItemID")), 1);
        is2 = setName(is2, ChatColor.DARK_AQUA + "MP7", null);
        inv.setItem(5, is2);

        /*
        MAG-7
         */
        ItemStack is3 = new ItemStack(Material.getMaterial(config.getInt("Weapons.MAG-7.ItemID")), 1);
        is3 = setName(is3, ChatColor.DARK_AQUA + "MAG-7", null);
        inv.setItem(24, is3);

        /*
        M249
         */
        ItemStack is4 = new ItemStack(Material.getMaterial(config.getInt("Weapons.M249.ItemID")), 1);
        is4 = setName(is4, ChatColor.DARK_AQUA + "M249", null);
        inv.setItem(41, is4);

        /*
        Negev
         */
        ItemStack is5 = new ItemStack(Material.getMaterial(config.getInt("Weapons.Negev.ItemID")), 1);
        is5 = setName(is5, ChatColor.DARK_AQUA + "Negev", null);
        inv.setItem(39, is5);

        player.openInventory(inv);
    }

    public static void pistoletsMenu(Player player) {
        player.closeInventory();
        Inventory inv = Bukkit.createInventory(null, 45, ChatColor.BLACK + "Pistolets");

        /*
        USP-S et Glock
         */
        if(mainBoard.getTeam("1").getName().contains(mainBoard.getPlayerTeam(player).getName())) {
            ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.USP-S.ItemID")), 1);
            is1 = setName(is1, ChatColor.DARK_AQUA + "USP-S", null);
            inv.setItem(3, is1);
        }
        else {
            ItemStack is1 = new ItemStack(Material.getMaterial(config.getInt("Weapons.GLOCK-18.ItemID")), 1);
            is1 = setName(is1, ChatColor.DARK_AQUA + "GLOCK-18", null);
            inv.setItem(3, is1);
        }

        /*
        P250
         */
        ItemStack is2 = new ItemStack(Material.getMaterial(config.getInt("Weapons.P250.ItemID")), 1);
        is2 = setName(is2, ChatColor.DARK_AQUA + "P250", null);
        inv.setItem(5, is2);

        /*
        Five Seven
         */
        ItemStack is3 = new ItemStack(Material.getMaterial(config.getInt("Weapons.Five-SeveN.ItemID")), 1);
        is3 = setName(is3, ChatColor.DARK_AQUA + "Five-SeveN", null);
        inv.setItem(24, is3);

        /*
        Deagle
         */
        ItemStack is4 = new ItemStack(Material.getMaterial(config.getInt("Weapons.Desert_Eagle.ItemID")), 1);
        is4 = setName(is4, ChatColor.DARK_AQUA + "Desert Eagle", null);
        inv.setItem(41, is4);

        player.openInventory(inv);
    }

    public static void closeShops() {
        for(Player online : getServer().getOnlinePlayers()) {
            online.closeInventory();
        }
    }
}
