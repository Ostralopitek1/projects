package fr.goldrush.ostralopitek.gungr;

import org.bukkit.ChatColor;
import org.bukkit.Material;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.plugin.Plugin;
import org.bukkit.scoreboard.Scoreboard;

import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.getOverWorld;
import static fr.goldrush.ostralopitek.gungr.UsefulFunctions.setName;
import static org.bukkit.Bukkit.getPluginManager;
import static org.bukkit.Bukkit.getScoreboardManager;


public class Weapons {

    static Plugin plugin = getPluginManager().getPlugin("GunGR");
    static final FileConfiguration config = plugin.getConfig();

    public static Material getPrimary(Player player) {
        Material material = null;
        ItemStack is = player.getInventory().getItem(0);
        if(is != null)  material = is.getType();
        return material;
    }

    public static Material getSecondary(Player player) {
        Material material = null;
        ItemStack is = player.getInventory().getItem(2);
        if(is != null)  material = is.getType();
        return material;
    }

    public static Material getMaterial(String weaponName) {
        Material material = Material.getMaterial(config.getInt("Weapons." + weaponName + ".ItemID"));
        return material;
    }

    public static String getName(Material material) {
        String weaponName = null;

        if(material == Material.getMaterial(config.getInt("Weapons.FAMAS.ItemID"))) weaponName = "FAMAS";
        else if(material == Material.getMaterial(config.getInt("Weapons.M4A1-S.ItemID"))) weaponName = "M4A1-S";
        else if(material == Material.getMaterial(config.getInt("Weapons.AK-47.ItemID"))) weaponName = "AK-47";
        else if(material == Material.getMaterial(config.getInt("Weapons.SSG_08.ItemID"))) weaponName = "SSG_08";
        else if(material == Material.getMaterial(config.getInt("Weapons.AUG.ItemID"))) weaponName = "AUG";
        else if(material == Material.getMaterial(config.getInt("Weapons.SG_553.ItemID"))) weaponName = "SG_553";
        else if(material == Material.getMaterial(config.getInt("Weapons.AWP.ItemID"))) weaponName = "AWP";
        else if(material == Material.getMaterial(config.getInt("Weapons.AUTO.ItemID"))) weaponName = "AUTO";

        else if(material == Material.getMaterial(config.getInt("Weapons.GLOCK-18.ItemID"))) weaponName = "GLOCK-18";
        else if(material == Material.getMaterial(config.getInt("Weapons.USP-S.ItemID"))) weaponName = "USP-S";
        else if(material == Material.getMaterial(config.getInt("Weapons.P250.ItemID"))) weaponName = "P250";

        else if(material == Material.getMaterial(config.getInt("Weapons.NOVA.ItemID"))) weaponName = "Nova";

        else if(material == Material.getMaterial(config.getInt("Weapons.P90.ItemID"))) weaponName = "P90";

        else if(material == Material.getMaterial(config.getInt("Weapons.KIT.ItemID"))) weaponName = "Kit de désamorçage";

        else if(material == Material.getMaterial(config.getInt("Weapons..ItemID"))) weaponName = "";

        return weaponName;
    }

    public static int getAmmoInMagazine(String weaponName) {
        int ammo = config.getInt("Weapons." + weaponName + ".Magazine");
        return ammo;
    }

    public static int getAmmoInMagazine(Material material) {
        String weaponName = getName(material);
        int ammo = 0;
        if(weaponName != null) {
            ammo = config.getInt("Weapons." + weaponName + ".Magazine");
        }
        return ammo;
    }

    public static int getAmmoInPocket(String weaponName) {
        int ammo = config.getInt("Weapons." + weaponName + ".Ammo");
        return ammo;
    }

    public static int getAmmoInPocket(Material material) {
        String weaponName = getName(material);
        int ammo = 0;
        if(weaponName != null) {
            ammo = config.getInt("Weapons." + weaponName + ".Ammo");
        }
        return ammo;
    }

    public static void addWeapon(Player player, String weaponName, String weaponType) {
        int ammoMag = Weapons.getAmmoInMagazine(weaponName);
        int ammoPocket = Weapons.getAmmoInPocket(weaponName);
        weaponName = ChatColor.stripColor(weaponName);
        ItemStack isWeapon = new ItemStack(Weapons.getMaterial(weaponName));
        isWeapon = setName(isWeapon, ChatColor.DARK_BLUE + weaponName, null);

        if(weaponType.contains("primary")) {
            ItemStack isAmmoMag = new ItemStack(Material.GLOWSTONE_DUST, ammoMag);
            isAmmoMag = setName(isAmmoMag, ChatColor.RED + "Munitions(arme principale)", null);
            ItemStack isAmmoPocket = new ItemStack(Material.GLOWSTONE_DUST, ammoPocket);
            isAmmoPocket = setName(isAmmoPocket, ChatColor.RED + "Munitions(arme principale)", null);

            player.getInventory().setItem(0, isWeapon);
            player.getInventory().setItem(1, isAmmoMag);
            player.getInventory().setItem(7, isAmmoPocket);
        }
        else {
            ItemStack isAmmoMag = new ItemStack(Material.DEAD_BUSH, ammoMag);
            isAmmoMag = setName(isAmmoMag, ChatColor.RED + "Munitions(arme secondaire)", null);
            ItemStack isAmmoPocket = new ItemStack(Material.DEAD_BUSH, ammoPocket);
            isAmmoPocket = setName(isAmmoPocket, ChatColor.RED + "Munitions(arme secondaire)", null);

            player.getInventory().setItem(2, isWeapon);
            player.getInventory().setItem(3, isAmmoMag);
            player.getInventory().setItem(8, isAmmoPocket);
        }
    }

    public static void refillAmmo(Player player) {
        ItemStack isPrim = player.getInventory().getItem(0);
        ItemStack isSecondary = player.getInventory().getItem(2);

        if(isPrim != null) {
            String weaponName = isPrim.getItemMeta().getDisplayName();
            weaponName = ChatColor.stripColor(weaponName);
            ItemStack ammoMag = new ItemStack(Material.GLOWSTONE_DUST, getAmmoInMagazine(weaponName));
            ammoMag = setName(ammoMag, ChatColor.RED + "Munitions(arme principale)", null);
            ItemStack ammoPocket = new ItemStack(Material.GLOWSTONE_DUST, getAmmoInPocket(weaponName));
            ammoPocket = setName(ammoPocket, ChatColor.RED + "Munitions(arme principale)", null);
            player.getInventory().setItem(1, ammoMag);
            player.getInventory().setItem(7, ammoPocket);
        }

        if(isSecondary != null) {
            String weaponName = isSecondary.getItemMeta().getDisplayName();
            weaponName = ChatColor.stripColor(weaponName);
            ItemStack ammoMag = new ItemStack(Material.DEAD_BUSH, getAmmoInMagazine(weaponName));
            ammoMag = setName(ammoMag, ChatColor.RED + "Munitions(arme secondaire)", null);
            ItemStack ammoPocket = new ItemStack(Material.DEAD_BUSH, getAmmoInPocket(weaponName));
            ammoPocket = setName(ammoPocket, ChatColor.RED + "Munitions(arme secondaire)", null);
            player.getInventory().setItem(3, ammoMag);
            player.getInventory().setItem(8, ammoPocket);
        }
    }

    public static long getFireInterval(Material material) {
        String weaponName = getName(material);
        return config.getLong("Weapons." + weaponName + ".FireTime");
    }

    public static int getDamageDistance(Material material) {
        String weaponName = getName(material);
        return config.getInt("Weapons." + weaponName + ".DamageDist");
    }

    public static double getReloadTime(Material material) {
        String weaponName = getName(material);
        return config.getDouble("Weapons." + weaponName + ".ReloadTime");
    }

    public static double getHurtLevel(Material material) {
        String weaponName = getName(material);
        return config.getInt("Weapons." + weaponName + ".Precision");
    }

    public static double getDamage(String weaponName) {
        return config.getDouble("Weapons." + weaponName + ".Damage");
    }

    public static double getDamage(Material material) {
        String weaponName = getName(material);
        return config.getDouble("Weapons." + weaponName + ".Damage");
    }

    public static void bombRemove() {
        Scoreboard mainBoard = getScoreboardManager().getMainScoreboard();
        int posX = mainBoard.getObjective("GameStats").getScore("bombeX").getScore();
        int posY = mainBoard.getObjective("GameStats").getScore("bombeY").getScore();
        int posZ = mainBoard.getObjective("GameStats").getScore("bombeZ").getScore();
        getOverWorld().getBlockAt(posX, posY, posZ).setType(Material.AIR);
    }
}
