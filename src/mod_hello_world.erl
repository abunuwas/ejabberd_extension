
-module(mod_hello_world).
%%-behaviour(gen_mod).

%% Required by ?INFO_MSG macros
-include("logger.hrl").
-include("ejabberd.hrl").
-include("jlib.hrl").

%% Add and remove hook module on startup and close

%% gen_mod API callbacks
-export([start/2, stop/1]).

-ifndef(LAGER).
-define(LAGER, 1).
-endif.

start(Host, _Opt) -> 
    ?INFO_MSG("Hello, ejabberd world!", []),
    ejabberd_hooks:add(user_send_packet, Host, ?MODULE, on_user_send_packet, 0),
    ok.

stop(_Host) -> 
    ?INFO_MSG("Bye bye, ejabberd world!", []),
    ejabberd_hooks:delete(user_send_packet, Host, ?MODULE, on_user_send_packet, 0),
    ok. 

on_user_send_packet(From, To, Packet) ->
    ?INFO_MSG(From+To+Packet, []),
    ok.
    

