
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
	process/2,
	disconnection/1,
    filter2_packet/1,
    filter3_packet/1,
    register_iq_handler/1,
    send_presences/1
	]).

-ifndef(LAGER).
-define(LAGER, 1).
-endif.

start(_Host, _Opt) -> 
    ejabberd_hooks:add(c2s_filter_packet, _Host, ?MODULE, filter2_packet, 50),
    ejabberd_hooks:add(filter_packet, global, ?MODULE, filter3_packet, 50),
    ?INFO_MSG("BUENO: Hello, ejabberd world!", []),
    ?INFO_MSG("BUENO: Before adding hook...", []),
    ejabberd_hooks:add(user_send_packet, _Host, ?MODULE, packeto, 50),
    ?INFO_MSG("BUENO: start user_send_packet hook", []),
    ejabberd_hooks:add(user_receive_packet, _Host, ?MODULE, packeto, 50),
    ?INFO_MSG("BUENO: start user_receive_packet hook", []),
    ejabberd_hooks:add(component_connected, global, ?MODULE, disconnection, 50),
    ?INFO_MSG("BUENO: component_connected hook with disconnection function", []),
    %ejabberd_local:register_iq_handler(global, "jabber:iq:first_component", ?MODULE, query_handler),
    ok.

stop(_Host) -> 
    ?INFO_MSG("BUENO: Bye bye, ejabberd world!", []),
    ejabberd_hooks:delete(user_send_packet, _Host, ?MODULE, packeto, 50),
    ejabberd_hooks:delete(user_receive_packet, _Host, ?MODULE, packeto, 50),
    ejabberd_hooks:delete(component_connected, _Host, ?MODULE, disconnection, 50),
    ok. 

send_presences(H) ->
	Sessions = ejabberd_sm:dirty_get_sessions_list(),
	To = jid:make(<<>>, H, <<>>),
	Packet = {xmlel,<<"presence">>,[{<<"from">>,<<"user1@localhost">>},{<<"to">>,<<"muc.localhost">>},{<<"type">>,<<"available">>}],[]},
	lists:foreach(
		fun({U, S, R}) ->
			From = jid:make(U, S, R),
			ejabberd_router:route(From, To, Packet)
		end, Sessions).


packeto(Packet, State, Jid_from, Jid_to) ->
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

packeto(Packet, State, Jid_from, Jid_to, _jid_from2) ->
    %?INFO_MSG("P A C K E T O : ", [binary_to_list(State)]),
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
	%Users = [binary_to_list(Username) ++ At ++ binary_to_list(Server) ++ Br || {Username, Server} <- ejabberd_auth:dirty_get_registered_users()],
	Users = [binary_to_list(Username) ++ At ++ binary_to_list(Server) ++ Br || {Username, Server} <- ejabberd_auth:dirty_get_registered_users()],
	Users.
    %%list = [io:format("~s@~s", [Username, Server]) || {Username, Server} <- ],
    %%io_list:format("~w", list).

disconnection(H) ->
    ?INFO_MSG("BUAHHHHHHHHH BUAHHHHHHHHHHHH BUAHHHHHHHHHHHHH BUAHHHHHHHHHHHHHHH: The component was disconnected!!!!!!!!!! ~p~n", [H]),
    Components = mod_first_component:get_pids_from_domain(H),
    ?INFO_MSG("Pids associated with the connecting domain: ~p~n", [Components]),
    NumComponents = length(Components),
    ?INFO_MSG("THIS IS THE NUM OF COMPONENTS: ~p~n", [NumComponents]),
    case NumComponents of
    	1 ->
    		?INFO_MSG("YAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY FIRST COMPONENT!!!!!!!!!!!!", []),
    		send_presences(H);
    	_ ->
    		?INFO_MSG("EEEEEEEEEEEEEEEEEEEEEE SORRY YOU'RE NOT THE FIRST COMPONENT ;) ---------------------------------------------", [])
    	end,
    %SysData = [sys:get_status(Pid) || Pid <- Components],
    %?INFO_MSG("AND THIS IS THEIR DATA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ~p~n", [SysData]),
    H.

filter2_packet({Acc, Server, C2SState, Feature, To, Packet}) ->
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(Acc)]),
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(Server)]),
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(C2SState)]),
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(Feature)]),
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(To)]),
    ?INFO_MSG("JAJAJAJAJAJJAJAJAJJAJAJAJAJJAJAJA ~p~n", [binary_to_list(Packet)]),
    Packet.

%filter_component_data({domain, Domain}) -> Domain.
%filter_component_data({ip, IP}) -> IP.
%filter_component_data({port, Port}) -> Port.

%call_sys() ->
%    receive 
%        {From, Pid} ->
%            Status = sys:get_status(Pid),
%            From ! {Status};
%        _ -> ok
%        end.

%get_pid_status(Pid) ->
%    SYS = spawn(?MODULE, call_sys, []),
%    SYS ! {self(), Pid},
%    receive 
%        {Status} ->
%            Status;
%        _ -> 
%        ?INFO_MSG("NOTHINGGGGGGGGGGGGGGGGGGG", [])
%    after 
%        2000 ->
%        get_pid_status(Pid)
%    end.


filter3_packet({ _From, _To, {xmlel, <<"iq">>, _Stanza_Header, Substanzas} } = Packet) ->
    ?INFO_MSG("JOJOJOJOJOJOJOJOJOJOOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJOJJOJOJOOJOJOJOJOJOJOJJO ~p~n", [Substanzas]),
    %case Substanzas of
        %[{ xmlel, <<"query">>, [ { _, <<"jabber:iq:first_component">> } ], ComponentData }] = Substanzas ->
            %?INFO_MSG("KEEP CALM!! WE ARE GOING TO CHECK WHETHER YOU ARE THE FIRST COMPONENT!!", []),
            %[ _, { xmlel, <<"component_data">>, DomainPortIP, _ }, _ ] = ComponentData,
            %[{_, Domain}] = lists:filter(fun({Tag, _}) -> Tag == <<"domain">> end, DomainPortIP),
            %?INFO_MSG("So your domain is ~p~n", [Domain]),
            %All_Pids = mod_first_component:get_pids_from_domain(Domain),
            %?INFO_MSG("All Pids associated with your domain are: ~p~n", [All_Pids]),
            %?INFO_MSG("We are going to see now which ports are linked to the pids", []),
            %A_Pid = lists:nth(1, All_Pids),
            %Another_Pid = lists:nth(2, All_Pids),
            %Info = sys:get_status(A_Pid),
            %?INFO_MSG("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ", [Info]),
            %Info2 = sys:get_status(Another_Pid),
            %?INFO_MSG("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ", [Info2]);            
            %Pids_Infos = mod_first_component:get_pids_info(All_Pids),
            %SItems = mod_first_component:get_pids_sitems(Pids_Infos),
            %SocketsData = mod_first_component:get_pids_socket_data(SItems),
            %Sockets = mod_first_component:get_pids_sockets(SocketsData),
            %Ips_Ports = mod_first_component:get_ips_ports_from_sockets(Sockets),
            %?INFO_MSG("The following ports are linked to the Pids associated to your domain: ", [Ips_Ports]),
            %[{_, IP}] = lists:filter(fun({Tag, _}) -> Tag == <<"ip">> end, DomainPortIP),
            %[{_, Port}] = lists:filter(fun({Tag, _}) -> Tag == <<"port">> end, DomainPortIP),
            %?INFO_MSG("And your IP+Port is the following: ~p ~p~n", [IP, Port]);
        %_ -> ok
    %end,
    Packet.
    
register_iq_handler(_) -> ok.