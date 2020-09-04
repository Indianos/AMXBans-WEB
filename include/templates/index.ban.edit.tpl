{extends 'master.tpl'}
{block name="head-title" prepend}{'menu_titles'|lang:'ban'} | {/block}

{block name="BODY"}
    {include "messages.tpl"}
    <div class="card mb-4" id="ban-details">
        <div class="card-header">
            {'editing'|lang}
            <span class="float-right">#{$ban.bid}</span>
        </div>
        <form class="card-body" action="{['bans', $ban.bid]|url}" method="post">
            {Site::makeFormAuth('PUT')}
            <a href="{['bans', $ban.bid]|url}" class="btn btn-outline-info">
                <span class="mr-1">&blacktriangleleft;</span>
                {'back'|lang}
            </a>
            <div class="row align-items-center">
                <div class="col-lg-3 col-sm-5 text-sm-right">{'nickname'|lang}</div>
                <div class="col"><input name="player_nick" class="form-control"
                                        value="{"player_nick"|input:$ban.player_nick}" /></div>
            </div>
            <div class="row align-items-center mt-1">
                <div class="col-lg-3 col-sm-5 text-sm-right">{'steamid'|lang}</div>
                <div class="col"><input name="player_id" class="form-control"
                                        value="{"player_id"|input:$ban.player_id}" /></div>
            </div>
            {if $can_user.view_ips}
                <div class="row align-items-center mt-1">
                    <div class="col-lg-3 col-sm-5 text-sm-right">{'ip'|lang}</div>
                    <div class="col"><input name="player_ip" class="form-control"
                                            value="{"player_ip"|input:$ban.player_ip}" /></div>
                </div>
                <div class="row align-items-center mt-1">
                    <div class="col-lg-3 col-sm-5 text-sm-right">{'ban_type'|lang}</div>
                    <div class="col">
                        <select name="ban_type" class="form-control">
                            {foreach 'ban_types'|lang as $type}
                                <option value="{$type@key}"{if $type@key == $ban.ban_type} selected{/if}>{$type}</option>
                                {if $type@iteration == 3}{break}{/if}
                            {/foreach}
                        </select>
                    </div>
                </div>
            {/if}
            <div class="row align-items-center mt-1">
                <div class="col-lg-3 col-sm-5 text-sm-right">{'reason'|lang}</div>
                <div class="col"><input name="ban_reason" class="form-control"
                                        value="{'ban_reason'|input:$ban.ban_reason}" /></div>
            </div>
            <div class="row align-items-center mt-1">
                <div class="col-lg-3 col-sm-5 text-sm-right">{length|lang}</div>
                <div class="col">
                    <div class="input-group">
                        <input name="ban_length" class="form-control" value="{"ban_length"|input:$ban.ban_length}" />
                        <div class="input-group-append"><span class="input-group-text">{'mins'|lang}</span></div>
                    </div>
                </div>
            </div>
            <div class="row align-items-center mt-5">
                <div class="col-lg-3 col-sm-5 text-sm-right">{'edit_reason'|lang}</div>
                <div class="col"><input name="edit_reason" class="form-control" value="{"edit_reason"|input}"
                                        required /></div>
            </div>
            <div class="text-right mt-2">
                <button class="btn btn-success">{'save'|lang}</button>
            </div>
        </form>
    </div>
    <div class="card mb-4">
        <div class="card-header">{'edit_history'|lang}</div>
        <div class="card-body">
            {foreach $ban.logs as $log}
                <div><b>{$log.admin_nick} @ {$log.created_at->format($lang_date_format)}</b>: {$log.edit_reason}</div>
                {if !$log@last}
                    <hr />
                {/if}
            {/foreach}
        </div>
    </div>
{/block}