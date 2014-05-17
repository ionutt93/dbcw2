﻿-- For the second question
CREATE OR REPLACE FUNCTION check_rating_update() RETURNS trigger AS $$
BEGIN 
	UPDATE game SET
        avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    WHERE id = NEW.gameId;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_update ON gameOwn;
CREATE TRIGGER check_update
	AFTER UPDATE OR INSERT ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE check_rating_update();

-- For the third question
CREATE OR REPLACE FUNCTION count_rating() RETURNS trigger AS $$
BEGIN 
	IF (TG_OP = 'DELETE') THEN
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=OLD.ID ) <= 10 THEN
			UPDATE game SET
				avgRate = NULL
			WHERE id = OLD.gameID;
		END IF;
		RETURN OLD;
	ELSEIF(TG_OP = 'INSERT') THEN
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=NEW.ID ) > 10 THEN
			UPDATE game SET
				avgRate = avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    		WHERE id = NEW.gameId;
		END IF;
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS show_rating ON gameOwn;
CREATE TRIGGER show_rating
	BEFORE INSERT OR DELETE ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE count_rating();

--Question 6
CREATE OR REPLACE FUNCTION check_score_range() RETURNS trigger AS $$
DECLARE
    myrank int;
    totalu int;
    ratio float;
    multiplier float;
BEGIN 

    
    SELECT count(highscore) INTO totalu FROM gameOwn WHERE gameid = OLD.gameid;
    SELECT q.rank INTO myrank FROM
        (SELECT row_number() OVER (ORDER BY highscore DESC) AS rank,userid FROM gameOwn
        WHERE gameid = OLD.gameid) AS q WHERE q.userid = OLD.userid;
    ratio := myrank/(totalu::float);
    CASE
        WHEN ratio < 0.25 THEN
            multiplier := 0.4;
        WHEN ratio BETWEEN 0.25 AND 0.5 THEN
            multiplier := 0.8;
        WHEN ratio BETWEEN 0.5 AND 0.75 THEN
            multiplier := 1.2;
        WHEN ratio > 0.75 THEN
            multiplier := 1.4;
    END CASE;

    RAISE NOTICE 'derp %', ratio;
    -- old +  diff*multiplier
    NEW.highscore := round(OLD.highscore + (NEW.highscore - OLD.highscore)*multiplier);


	IF NEW.highscore < (SELECT minimum FROM game WHERE ID=NEW.gameID) THEN
		RAISE EXCEPTION 'New Highscore is too low.';
        RETURN NULL;
	ELSEIF NEW.highscore > (SELECT maximum FROM game WHERE ID=NEW.gameID) THEN
		RAISE EXCEPTION 'New Highscore is too high.';
        RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_score ON gameOwn;
CREATE TRIGGER check_score
	BEFORE UPDATE OF highScore ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE check_score_range();

CREATE OR REPLACE FUNCTION check_gameAch() RETURNS trigger AS $$
DECLARE
    n int;
    totalsum int;

    asum int;
    cn int;
BEGIN 
    n := 100;
    totalsum := 1000;
    cn := count(id) FROM "gameAch" WHERE "gameAch".gameid = NEW.gameid;
    asum := sum(value) FROM "gameAch" WHERE "gameAch".gameid = NEW.gameid;
    IF cn >= n THEN
        RAISE EXCEPTION 'A game cannot have more than % achievements', n;
        RETURN NULL;
    END IF;
    IF asum >= totalsum THEN
        RAISE EXCEPTION 'A game cannot have more than % total value from achievements', totalsum;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS check_gameAch ON "gameAch";
CREATE TRIGGER check_gameAch
	BEFORE INSERT ON "gameAch"
	FOR EACH ROW
	EXECUTE PROCEDURE check_gameAch();



--Question 8
-- Assume lock deletes the account
CREATE OR REPLACE FUNCTION check_username_offensive() RETURNS trigger AS $$
BEGIN 
	--IF (SELECT username FROM "user" WHERE ID=NEW.ID)
	IF NEW.username SIMILAR TO 
		'4r5e|yard|cunt|punt|5h1t|5hit|a_s_s|a2m|a55|adult|amateur
		|anal|anal impaler|anal leakage|anilingus|anus|ar5e|arrse|arse|arsehole|ass|ass fuck|asses|assfucker|ass-fucker|
		assfukka|asshole|asshole|assholes|assmucus|assmunch|asswhole|autoerotic|bitch|b00bs|b17ch|b1tch|ballbag|ballsack|
		bang ones box|bangbros|bareback|bastard|beastial|beastiality|beef curtain|bellend|bestial|bestiality|bi+ch|biatch
		|bimbos|birdlock|bitch|bitch tit|bitcher|bitchers|bitches|bitchin|bitching|bloody|blow job|blow me|blow mud|blowjob
		|blowjobs|blue waffle|blumpkin|boiolas|bollock|bollok|boner|boob|boobs|booobs|boooobs|booooobs|booooooobs|breasts|
		buceta|bugger|bum|bunny fucker|bust a load|busty|butt|butt fuck|butthole|buttmuch|buttplug|c0ck|c0cksucker|carpet muncher
		|carpetmuncher|cawk|chink|choade|chota bags|cipa|cl1t|clit|clit licker|clitoris|clits|clitty litter|clusterfuck|cnut|
		cock|cock pocket|cock snot|cockface|cockhead|cockmunch|cockmuncher|cocks|cocksuck|cocksucked|cocksucker|cock-sucker|
		cocksucking|cocksucks|cocksuka|cocksukka|cok|cokmuncher|coksucka|coon|cop some wood|cornhole|corp whore|cox|cum|cum chugger
		|cum dumpster|cum freak|cum guzzler|cumdump|cummer|cumming|cums|cumshot|cunilingus|cunillingus|cunnilingus|cunt|cunt hair
		|cuntbag|cuntlick|cuntlicker|cuntlicking|cunts|cuntsicle|cunt-struck|cut rope|cyalis|cyberfuc|cyberfuck|cyberfucked|
		cyberfucker|cyberfuckers|cyberfucking|d1ck|damn|dick|dick hole|dick shy|dickhead|dildo|dildos|dink|dinks|dirsa|dirty Sanchez
		|dlck|dog-fucker|doggie style|doggiestyle|doggin|dogging|donkeyribber|doosh|duche|dyke|eat a dick|eat hair pie|ejaculate|
		ejaculated|ejaculates|ejaculating|ejaculatings|ejaculation|ejakulate|erotic|fuck|fucker|f_u_c_k|f4nny|facial|fag|
		fagging|faggitt|faggot|faggs|fagot|fagots|fags|fanny|fannyflaps|fannyfucker|fanyy|fatass|fcuk|fcuker|fcuking|feck|fecker|
		felching|fellate|fellatio|fingerfuck|fingerfucked|fingerfucker|fingerfuckers|fingerfucking|fingerfucks|fist fuck|fistfuck|
		fistfucked|fistfucker|fistfuckers|fistfucking|fistfuckings|fistfucks|flange|flog the log|fook|fooker|fuck hole|fuck puppet|
		fuck trophy|fuck yo mama|fuck|fucka|fuck-ass|fuck-bitch|fucked|fucker|fuckers|fuckhead|fuckheads|fuckin|fucking|fuckings|
		fuckingshitmotherfucker|fuckme|fuckmeat|fucks|fucktoy|fuckwhit|fuckwit|fudge packer|fudgepacker|fuk|fuker|fukker|fukkin|fuks
		|fukwhit|fukwit|fux|fux0r|gangbang|gangbang|gang-bang|gangbanged|gangbangs|gassy ass|gaylord|gaysex|goatse|god|god damn|
		god-dam|goddamn|goddamned|god-damned|ham flap|hardcoresex|hell|heshe|hoar|hoare|hoer|homo|homoerotic|hore|horniest|horny|
		hotsex|how to kill|how to murdep|jackoff|jack-off|jap|jerk|jerk-off|jism|jiz|jizm|jizz|kawk|kinky Jesus|knob|knob end|knobead
		|knobed|knobend|knobend|knobhead|knobjocky|knobjokey|kock|kondum|kondums|kum|kummer|kumming|kums|kunilingus|kwif|l3i+ch|l3itch
		|labia|LEN|lmao|lmfao|lmfao|lust|lusting|m0f0|m0fo|m45terbate|ma5terb8|ma5terbate|mafugly|masochist|masterb8|masterbat*
		|masterbat3|masterbate|master-bate|masterbation|masterbations|masturbate|mof0|mofo|mo-fo|mothafuck|mothafucka|mothafuckas|
		mothafuckaz|mothafucked|mothafucker|mothafuckers|mothafuckin|mothafucking|mothafuckings|mothafucks|mother fucker|mother fucker
		|motherfuck|motherfucked|motherfucker|motherfuckers|motherfuckin|motherfucking|motherfuckings|motherfuckka|motherfucks|muff|
		muff puff|mutha|muthafecker|muthafuckker|muther|mutherfucker|n1gga|n1gger|nazi|need the dick|nigg3r|nigg4h|nigga|niggah|niggas
		|niggaz|nigger|niggers|nob|nob jokey|nobhead|nobjocky|nobjokey|numbnuts|nut butter|nutsack|omg|orgasim|orgasims|orgasm|orgasms|
		p0rn|pawn|pecker|penis|penisfucker|phonesex|phuck|phuk|phuked|phuking|phukked|phukking|phuks|phuq|pigfucker|pimpis|piss|pissed|
		pisser|pissers|pisses|pissflaps|pissin|pissing|pissoff|poop|porn|porno|pornography|pornos|prick|pricks|pron|pube|pusse|pussi|
		pussies|pussy|pussy fart|pussy palace|pussys|queaf|queer|rectum|retard|rimjaw|rimming|s hit|s.o.b.|s_h_i_t|sadism|sadist|sandbar
		|sausage queen|schlong|screwing|scroat|scrote|scrotum|semen|sex|sh!+|sh!t|sh1t|shag|shagger|shaggin|shagging|shemale|shi+|shit|
		shit fucker|shitdick|shite|shited|shitey|shitfuck|shitfull|shithead|shiting|shitings|shits|shitted|shitter|shitters|shitting
		|shittings|shitty|skank|slope|slut|slut bucket|sluts|smegma|smut|snatch|son-of-a-bitch|spac|spunk|t1tt1e5|t1tties|teets|teez|
		testical|testicle|tit|tit wank|titfuck|tits|titt|tittie5|tittiefucker|titties|tittyfuck|tittywank|titwank|tosser|turd|tw4t|twat
		|twathead|twatty|twunt|twunter|v14gra|v1gra|vagina|viagra|vulva|w00se|wang|wank|wanker|wanky|whoar|whore|willies|willy|wtf|
		xrated|xxx' THEN
		DELETE FROM "user" WHERE ID=NEW.ID;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_username ON "user";
CREATE TRIGGER check_username
	AFTER INSERT ON "user"
	FOR EACH ROW
	EXECUTE PROCEDURE check_username_offensive();




