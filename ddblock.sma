#include <amxmodx>
#include <amxmisc>
#include <reapi>

public plugin_init() {
    register_plugin("DoubleDuck Block", "1.4", "kreedzru");
    RegisterHookChain(RG_PM_Move, "PM_Move_Post", true);

    register_cvar("ddblock_enable", "1"); 

    LoadConfig();
}

public PM_Move_Post(pPlayer) {
    if (!get_pcvar_num(get_cvar_pointer("ddblock_enable"))) {
        return;
    }

    if (!is_user_alive(pPlayer)) {
        return;
    }

    if (get_pmove(pm_bInDuck)) {
        new Float:fVelocity[3];
        get_pmove(pm_velocity, fVelocity);
        fVelocity[0] = fVelocity[1] = 0.0;
        set_pmove(pm_velocity, fVelocity);
    }
}

public LoadConfig() {
    new configDir[64], configFile[128];

    get_configsdir(configDir, charsmax(configDir));
    format(configFile, charsmax(configFile), "%s/ddblock.cfg", configDir);

    if (!file_exists(configFile)) {
        write_file(configFile, "; DoubleDuck Block Configuration File");
        write_file(configFile, "; Version: 1.4");
        write_file(configFile, "; Author: Kreedzru");
        write_file(configFile, "; GitHub: github.com/kreedzru");
        write_file(configFile, "");
        write_file(configFile, "; Включение/выключение плагина (1 - включено, 0 - выключено)");
        write_file(configFile, "ddblock_enable 1");

        log_to_file("ddblock.log", "[DDBlock] Конфигурационный файл создан: %s", configFile);
    } 
    else {
        log_to_file("ddblock.log", "[DDBlock] Конфигурационный файл уже существует: %s", configFile);
    }

    LoadCVarsFromFile(configFile);
}

public LoadCVarsFromFile(const fileName[]) {
    new file = fopen(fileName, "rt");
    if (!file) {
        log_to_file("ddblock.log", "[DDBlock] Ошибка: не удалось открыть файл %s", fileName);
        return;
    }

    new line[256], key[64], value[64];
    while (!feof(file)) {
        fgets(file, line, charsmax(line));

        trim(line);
        if (line[0] == ';' || line[0] == '0') {
            continue;
        }

        parse(line, key, charsmax(key), value, charsmax(value), " ");

        if (equal(key, "ddblock_enable")) {
            set_cvar_num("ddblock_enable", str_to_num(value));
            //log_to_file("ddblock.log", "[DDBlock] Загружено значение: ddblock_enable=%d", str_to_num(value));
        }
    }

    fclose(file);
    log_to_file("ddblock.log", "[DDBlock] Значения кваров загружены из файла: %s", fileName);
}
