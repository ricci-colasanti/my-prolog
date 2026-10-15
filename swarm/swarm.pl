% ============================================================
% THE SPRAWLt
% Neon Sprawl, 2087. 
% ============================================================


% --- Who exists ---
operative(vex).
operative(kilo).
operative(nix).
operative(sable).
operative(rook).

% --- Specialties ---
specialty(vex, netrunning).
specialty(kilo, combat).
specialty(nix, surveillance).
specialty(sable, social).

% --- Gear ---
gear(vex, top_deck).
gear(kilo, military_chrome).
gear(nix, drone_swarm).
gear(sable, forged_id_kit).
gear(rook, beat_up_multitool).

% --- What gear provides ---
provides(top_deck, netrunning).
provides(military_chrome, combat).
provides(drone_swarm, surveillance).
provides(forged_id_kit, social).
provides(forged_id_kit, infiltration).
provides(beat_up_multitool, infiltration).

% --- Baggage ---
banned_from(vex, arasaka_grid).
banned_from(vex, militech_grid).
banned_from(vex, helix_grid).
owes_favor(kilo, iron_saints_gang).
afraid_of(nix, deep_water).
has_bounty(sable, downtown_district).

% --- Trust signals ---
burned_job(vex).
divided_loyalty(kilo).
divided_loyalty(sable).
has_heat(vex).
has_heat(sable).

% --- Jobs ---
job(helix_data_grab).
job(bodyguard_meet).
job(rooftop_stakeout).

% --- What each job requires (a list of skills) ---
requires(helix_data_grab, [infiltration, netrunning]).
requires(bodyguard_meet,   [combat, social]).
requires(rooftop_stakeout, [surveillance]).


can_do(Op,Skill):-
	specialty(Op,Skill).

can_do(Op,Skill) :-
	gear(Op,G),
	provides(G,Skill).

eligible(Op,Job) :-
	operative(Op),% bound: checks Op is in the crew.
	              % unbound: generates each operative in turn.
	job(Job), % bound: checks if there  is a job.
	          % unbound: generates each job in turn.
	requires(Job, Skills), % -- gets the list of skills
	can_do_all(Op,Skills). % -- checks the list of skills against each OP

can_do_all(_,[]). % List empty so succed

can_do_all(Op,[Skill | Rest]) :-  % Split list into head (Skill) and tail (Rest).
	can_do(Op,Skill), % -- checks that skill against Op
	can_do_all(Op,Rest). % -- checks the rest of the list.
	% Succeeds only if can_do holds for every skill in the list.
    % Fails at the first skill that can't be done — failure propagates up.
