<?php
/**
 *    AMXBans v7
 * Copyright 2018 by SeToY & |PJ|ShOrTy, indianiso1
 * This file is part of AMXBans.
 *
 * AMXBans is free software, but it's licensed under the Creative Commons - Attribution-NonCommercial-ShareAlike 2.0
 * AMXBans is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * You should have received a copy of the cc-nC-SA along with AMXBans.
 * If not, see http://creativecommons.org/licenses/by-nc-sa/2.0/
 */

/**
 * @param string      $action
 * @param string      $context
 * @param string|null $user
 * @throws Exception
 */
function db_log(string $action, string $context, $user = null): void
{
    $log             = new \Models\Log();
    $log->ip         = $_SERVER['REMOTE_ADDR'];
    $log->username   = $user ?? Auth::get('username');
    $log->action     = $action;
    $log->remarks    = $context;
    $log->created_at = new DateTime();
    $log->save();
}

function db_size()
{
    global $config;
    $db_size = 0;

    $q = $config->getDb()->prepare("SHOW TABLE STATUS FROM `{$config->getDb(true)}` LIKE '{$config->dbPrefix}_%'");
    if (!$q->execute()) {
        return false;
    }

    while ($value = $q->fetch(PDO::FETCH_ASSOC)) {
        $db_size += $value["Data_length"] + $value['Index_length'];
    }
    return $db_size;
}

function format_size($size)
{
    if ($size >= 1073741824) {
        return round(($size / 1073741824), 2) . "GB";
    } elseif ($size >= 1048576) {
        return round(($size / 1048576), 2) . "MB";
    } elseif ($size >= 1024) {
        return round(($size / 1024), 2) . " KB";
    }

    return $size ? $size . " B" : false;
}

function init_autoload($class)
{
    $in_folders = [
        'Controllers' => __DIR__ . DIRECTORY_SEPARATOR . '%1$s' . DIRECTORY_SEPARATOR . '%2$s.%3$s.inc',
        'Models'      => __DIR__ . DIRECTORY_SEPARATOR . '%1$s' . DIRECTORY_SEPARATOR . '%3$s.inc',
        'Support'     => __DIR__ . DIRECTORY_SEPARATOR . '%1$s' . DIRECTORY_SEPARATOR . '%3$s.inc',
    ];
    if (file_exists(__DIR__ . '/class.' . $class . '.inc')) {
        require_once __DIR__ . DIRECTORY_SEPARATOR . "class.$class.inc";
    } else {
        $class = explode("\\", $class);
        $c     = array_pop($class);
        $ns    = implode(DIRECTORY_SEPARATOR, $class);

        $php = explode('.', substr($_SERVER['SCRIPT_NAME'], strlen(dirname($_SERVER['SCRIPT_NAME']))))[0];
        $php = substr($php, is_numeric(strpos($php, '/')) ? strpos($php, '/') + 1 : 0);

        if (in_array($ns, array_keys($in_folders))) {
            $tpl = sprintf($in_folders[$ns], $ns, $php, $c);
            if (!file_exists($tpl)) {
                die(header('HTTP/1.1 500'));
            }
            require_once $tpl;
        } elseif (file_exists(__DIR__ . "/$ns/$php.$c.inc")) {
            require_once __DIR__ . "/$ns/$php.$c.inc";
        }
    }
    return;
}

function sql_operators()
{
    return ['=', '<', '>', '<=', '>=', '!=', 'LIKE', 'NOT LIKE', 'IN', 'NOT IN', 'IS', 'IS NOT'];
}

function snakeToCamel($string)
{
    $string = ucwords(str_replace('_', ' ', $string));
    $string = str_replace(' ', '', $string);
    return lcfirst($string);
}

function return_bytes($val)
{
    // https://www.php.net/manual/en/faq.using.php#faq.using.shorthandbytes
    $last = strtolower(substr($val, -1));
    $val  = (int)trim($val);
    switch ($last) {
        // The 'G' modifier is available since PHP 5.1.0
        case 'g':
            $val *= 1024;
        case 'm':
            $val *= 1024;
        case 'k':
            $val *= 1024;
    }

    return $val;
}

function toBool($value): bool
{
    return ($value === 'on' OR $value === 'On' OR $value == 'Yes' OR $value == 'yes' OR $value > 0 or $value == true);
}

function now(): DateTime
{
    return new DateTime();
}