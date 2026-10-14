% ============================================================
% THE SPRAWL — crew sheet
% Neon Sprawl, 2087. Facts only. No rules yet.
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


can_do(Op,Skill):-
	writeln(here1(Op)),
	specialty(Op,Skill).

can_do(Op,Skill) :-
	gear(Op,G),
	writeln(here2(Op)),
	provides(G,Skill).
