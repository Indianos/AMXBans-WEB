{extends file="master.tpl"}
{block name="head-title" prepend}{'admin_menu_subtitles'|lang:'web':'settings'} - {'admin_menu_titles'|lang:'web'} | {/block}

{block name="BODY"}
    {include file="messages.tpl"}
    {if Auth::hasPermission('websettings_view')}
        <h2>
            {'web_settings'|lang}
            {if Auth::hasPermission('websettings_edit')}<small class="float-right">
                <button form="form" class="btn btn-success">{'save'|lang}</button>
                </small>{/if}
        </h2>
        <form id="form" method="post">
            {foreach $settings as $key => $setting}
                <div class="row mb-2">
                    <div class="col-auto col-md-6 col-lg-3 font-weight-bold align-self-center text-md-right">{'settings_names'|lang:$key}</div>
                    <div class="col">
                        {if $key == 'default_lang'}
                            {html_options name=$key options=$availLangs selected=$setting required="required" class="form-control"}
                        {elseif $key == 'start_page'}
                            <select name="{$key}" class="form-control" required>
                                {foreach Config::start_pages as $k => $v}
                                    <option value="{$k}"{if $k == $setting} selected{/if}>{$v|lang}</option>
                                {/foreach}
                            </select>
                        {elseif $key|in_array:$appends}
                            <input name="{$key}" required class="form-control" value="{"; "|implode:$setting}" />
                        {elseif $key|in_array:$arrays}
                            <input name="{$key}" required class="form-control" value="{"; "|implode:$setting}" />
                        {elseif $key|in_array:$booleans}
                            {foreach $bool as $v => $name}
                                <label class="form-control mb-0">
                                    <input type="radio" name="{$key}" value="{$v}"
                                           required{if $setting == $v} checked{/if}> {$name}
                                </label>
                            {/foreach}
                        {else}
                            <input name="{$key}" required class="form-control" value="{$setting}" />
                        {/if}
                    </div>
                </div>
            {/foreach}
        </form>
    {else}
        <div class="alert alert-danger">{'no_access'|lang}</div>
    {/if}
{/block}