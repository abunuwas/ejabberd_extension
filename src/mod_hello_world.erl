
-module(mod_hello_world).

-author("Jose Haro").

%%-behaviour(gen_mod).

%% Required by ?INFO_MSG macros
-include("logger.hrl").
-include("ejabberd.hrl").
-include("jlib.hrl").

%% Add and remove hook module on startup and close

%% gen_mod API callbacks
-export([
	start/2, 
	stop/1, 
	packeto/4,
	packeto/5,
	process/2
	]).

-ifndef(LAGER).
-define(LAGER, 1).
-endif.

start(_Host, _Opt) -> 
    ?INFO_MSG("BUENO: Hello, ejabberd world!", []),
    ?INFO_MSG("BUENO: Before adding hook...", []),
    ejabberd_hooks:add(user_send_packet, _Host, ?MODULE, packeto, 50),
    ?INFO_MSG("BUENO: start user_send_packet hook", []),
    ejabberd_hooks:add(user_receive_packet, _Host, ?MODULE, packeto, 50),
    ?INFO_MSG("BUENO: start user_receive_packet hook", []),
    ok.

stop(_Host) -> 
    ?INFO_MSG("BUENO: Bye bye, ejabberd world!", []),
    ejabberd_hooks:delete(user_send_packet, _Host, ?MODULE, packeto, 50),
    ejabberd_hooks:delete(user_receive_packet, _Host, ?MODULE, packeto, 50),
    ok. 

packeto(Packet, _state, Jid_from, Jid_to) ->
	{_, Username, _, _, _, _, _} = Jid_from,
	{_, Subdomain, _, _, _, _, _} = Jid_to,
	{_, Stanza, _, _} = Packet,
    ok = ?INFO_MSG("BUENO BUENO BUENO: a packet was sent by ~p~n, to ~p~n, type: ~p~n", [
    																					binary_to_list(Username),
    																					binary_to_list(Subdomain),
    																					binary_to_list(Stanza)
    																					]
    																					),
    Packet.

packeto(Packet, _state, Jid_from, Jid_to, _jid_from2) ->
	{_, Username, _, _, _, _, _} = Jid_from,
	{_, _, Subdomain, _, _, _, _} = Jid_to,
	{_, Stanza, _, _} = Packet,
    ok = ?INFO_MSG("BUENO BUENO BUENO: a packet was sent by ~p, to ~p, type: ~p~n", [
    																					binary_to_list(Username),
    																					binary_to_list(Subdomain),
    																					binary_to_list(Stanza)
    																					]
    																					),
    Packet.

process(_Path, _Request) ->
	At = "@",
	Br = "<br/>",
	Users = [binary_to_list(Username) ++ At ++ binary_to_list(Server) ++ Br || {Username, Server} <- ejabberd_auth:dirty_get_registered_users()],
	Users.
    %%list = [io:format("~s@~s", [Username, Server]) || {Username, Server} <- ],
    %%io_list:format("~w", list).
    
