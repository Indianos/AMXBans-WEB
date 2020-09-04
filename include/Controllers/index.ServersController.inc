<?php
/**
 *    AMXBans v7
 * Copyright 2020 by indianiso1
 * This file is part of AMXBans.
 *
 * AMXBans is free software, but it's licensed under the Creative Commons - Attribution-NonCommercial-ShareAlike 2.0
 * AMXBans is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * You should have received a copy of the cc-nC-SA along with AMXBans.
 * If not, see http://creativecommons.org/licenses/by-nc-sa/2.0/
 */

/**  */

namespace Controllers;

use Models\AMXAdmin;
use Models\Ban;
use Models\DB;
use Models\Server;
use Support\BaseController;
use Support\Path;

/**
 * Class ServersController
 *
 * @package Controllers
 */
class ServersController extends BaseController
{
    public function index()
    {
        //fetch server_information
        $servers = Server::query()->select();
        $this->site->output->assign("servers", $servers);

        /**
         *
         *        Stats
         *
         */
        $this->site->output->assign('stats', [
            'total'     => Ban::query()->count('bid'),
            'permanent' => Ban::query()->where('ban_length', 0)->count('bid'),
            'temp'      => (int)DB::selectRaw("SELECT COUNT(bid) as count FROM {$this->site->config->getDb()->prefix}_bans WHERE ban_created+(ban_length*60) > UNIX_TIMESTAMP()")[0]->count,
            'admins'    => AMXAdmin::query()->count('id'),
            'servers'   => Server::query()->count('id'),
        ]);
        /**
         *
         *        Latest Ban
         *
         */
        $lb = Ban::query()->orderBy('ban_created', true)->selectOne([
            'bid',
            'player_nick',
            'player_id',
            'ban_length',
            'ban_created',
            'ban_reason',
        ]);

        if ($lb->ban_length > 0) {
            $lb->ban_length = $lb->ban_length * 60;
        }
        $this->site->output->assign('last_ban', $lb);

        return $this->site->output->display('index.servers.tpl');
    }

    public function ajaxServerInfo($server)
    {
        $server = Server::find($server);
        if (!$server->exists) {
            return json_encode([
                'success' => false,
                'message' => \Lang::get('server_not_found'),
            ]);
        }

        [$ip, $port] = explode(":", $server->address);
        if (!$ip || !$port) {
            return json_encode([
                'success' => false,
                'message' => \Lang::get('server_not_found'),
            ]);
        }

        try {
            $rcon = new \Rcon($ip, $port);

        } catch (\Exception $e) {
            return json_encode([
                'success' => false,
                'message' => $e->getMessage(),
            ]);
        }
        if (!($infos = $rcon->Info())) {
            return json_encode([
                'success' => false,
                'message' => \Lang::get('server_cannot_connect'),
            ]);
        }

        $out['players'] = [];
        foreach ((array)$rcon->Players() as $player) {
            $out['players'][] = [
                "name"  => htmlspecialchars($player['name']),
                "kills" => $player['frag'],
                "time"  => $player['time'],
            ];
        }

        //check if mappic exists
        $mapPic = "/webSources/images/maps/{$infos['mod']}/{$infos['map']}.jpg";

        //main server info
        $rules = $rcon->ServerRules();
        $out['info'] = [
            'RULES' => $rules,
            "hostname"     => $infos['name'],
            'address'      => $server['address'],
            "map"          => $infos['map'],
            "mod"          => $infos['mod'],
            'players'      => [
                'active' => $infos['activeplayers'],
                "bots"   => $infos['botplayers'],
                "max"    => $infos['maxplayers'],
            ],
            "dedicated"    => ($infos['dedicated'] == "d") ? "Dedicated" : "Listen",
            "os"           => ($infos['os'] == "l") ? "Linux" : "Windows",
            "password"     => (bool)$infos['password'],
            "timeleft"     => $rules['amx_timeleft'] ?? '-:--',
            "nextmap"      => $rules['amx_nextmap'] ?? '',
            "friendlyFire" => (bool)($rules['mp_friendlyfire'] ?? false),
            "picture"      => Path::getBaseURL() . (file_exists(Path::getRootPath() . $mapPic) ? $mapPic : "/webSources/images/maps/noimage.jpg"),
            'vac'          => (bool)$infos['secure'],
        ];

        $out['lang'] = [
            'players'      => \Lang::get('players_online'),
            'player'       => \Lang::get('player_info'),
            'address'     => \Lang::get('address'), // TODO: edit the key in template
            'friendlyFire' => \Lang::get('friendly_fire'),
            'password'     => \Lang::get('server_password'),
            'map'          => \Lang::get('map'),
            'timeleft'     => \Lang::get('timeleft'),
            'nextmap'      => \Lang::get('nextmap'),
            'yes'          => ucfirst(\Lang::get('yes')),
            'no'           => ucfirst(\Lang::get('no')),
        ];

        header('Content-Type: application/json');
        $out['success'] = true;
        echo json_encode($out);
    }
}