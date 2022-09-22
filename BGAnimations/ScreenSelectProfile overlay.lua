-- This was shamelessly stolen from the default Soundwaves theme.
-- It's pretty goddamn horrible and I have to do it from scracth anyway. ~Sudo
local ThemeColor = LoadModule('Theme.Colors.lua')

function GetLocalProfiles()
	local t = {};

	function GetSongsPlayedString(numSongs)
		return numSongs == 1 and Screen.String("SingularSongPlayed") or Screen.String("SeveralSongsPlayed")
	end

	for p = 0, PROFILEMAN:GetNumLocalProfiles() - 1 do
		local profile=PROFILEMAN:GetLocalProfileFromIndex(p);
		local ProfileCard = Def.ActorFrame {
			Def.Sprite{
				Texture=LoadModule("Options.GetProfileData.lua")(p,true)["Image"];
				InitCommand=function(self)
					self:setsize(52,52):y(-3):x(80):fadeleft(1):faderight(1):ztest(true):skewx(0.5)
				end;
				OffCommand=function(self) self:linear(0.1):diffusealpha(0) end;
			};
			Def.BitmapText {
				Font="Common Normal";
				Text=LoadModule("Options.GetProfileData.lua")(p,true)["Name"];
				InitCommand=function(self) self:horizalign(left):shadowlength(1):xy(-110,-12):zoom(1):ztest(true):skewx(0.5) end;
				OffCommand=function(self) self:linear(0.1):diffusealpha(0) end;
			};
			Def.BitmapText {
				Font="Common Normal";
				InitCommand=function(self) self:horizalign(left):shadowlength(1):xy(-110,12):zoom(0.6):vertspacing(-8):ztest(true):skewx(0.5) end;
				BeginCommand=function(self)
					local numSongsPlayed = profile:GetNumTotalSongsPlayed();
					self:settext( string.format( GetSongsPlayedString( numSongsPlayed ), numSongsPlayed ) )
				end;
				OffCommand=function(self) self:linear(0.1):diffusealpha(0) end;
			};
		};
		t[#t+1]=ProfileCard;
	end;

	return t;
end;

function LoadCard(cColor)
	local t = Def.ActorFrame {
		Def.Quad {
			InitCommand=function(self) self:vertalign(middle):zoomto(270,0):diffuse(cColor):diffusealpha(0.75) end;
			OnCommand=function(self) self:easeinoutexpo(0.25):zoomto(270,400) end;
			OffCommand=function(self) self:easeinoutexpo(0.5):zoomto(270,0):sleep(0.5):diffusealpha(0) end;
		};
	};
	return t
end
function LoadPlayerStuff(Player)
	local t = {};

	local pn = (Player == PLAYER_1) and 1 or 2;

--[[ 	local t = LoadActor(THEME:GetPathB('', '_frame 3x3'), 'metal', 200, 230) .. {
		Name = 'BigFrame';
	}; --]]
		
	t[#t+1] = Def.ActorFrame {
		Name = 'JoinFrame';
		LoadCard(color("0,0,0,0.5"));
		Def.BitmapText {
			Font="Common Normal";
			InitCommand=function(self) self:shadowlength(1):zoom(1):skewx(0.5) end;
			OnCommand=function(self) 
			self:settext(Screen.String("PressStart"));
			self:diffuseshift():effectcolor1(Color('White')):effectcolor2(color("0.5,0.5,0.5")) end;
		};
	};
	
	t[#t+1] = Def.ActorFrame {
		Name = 'BigFrame';
		LoadCard(ColorDarkTone(PlayerDarkColor(Player)));
	};
	t[#t+1] = Def.ActorFrame {
		Name = 'SmallFrame';
		InitCommand=function(self) self:y(-2) end;
		OnCommand=function(self) self:diffusealpha(0):sleep(0.14):linear(0.2):diffusealpha(1) end;
		Def.Quad {
			InitCommand=function(self) self:zoomto(270,64) end;
			OnCommand=function(self) self:diffuse(ColorLightTone(PlayerColor(Player))):diffuserightedge(ColorDarkTone(PlayerColor(Player))) end;
		};
		Def.Quad {
			InitCommand=function(self) self:zoomto(270,6):vertalign(top):y(-32) end;
			OnCommand=function(self) self:diffuse(PlayerColor(Player)):diffusealpha(0.6)  end;
		};			
		Def.Quad {
			InitCommand=function(self) self:zoomto(270,6):vertalign(bottom):y(32) end;
			OnCommand=function(self) self:diffuse(PlayerColor(Player)):diffusealpha(0.6)  end;
		};		
	};

	t[#t+1] = Def.ActorScroller{
		Name = 'Scroller';
		NumItemsToDraw=6;
		OnCommand=function(self) 
			self:y(1):SetFastCatchup(true):SetMask(300,58):SetSecondsPerItem(0.15) 
			self:diffusealpha(0):sleep(0.14):linear(0.2):diffusealpha(1)
		end;
		TransformFunction=function(self, offset, itemIndex, numItems)
			local focus = scale(math.abs(offset),0,2,1,0);
			self:visible(false);
			self:y(math.floor( offset*64 ));
-- 			self:zoomy( focus );
-- 			self:z(-math.abs(offset));
-- 			self:zoom(focus);
		end;
		OffCommand=function(self) self:linear(0.1):diffusealpha(0) end;
		children = GetLocalProfiles();
	};
	
	t[#t+1] = Def.ActorFrame {
		Name = "EffectFrame";
	};
	t[#t+1] = Def.BitmapText {
		Font="Common Normal";
		Name = 'SelectedProfileText';
		InitCommand=function(self) 
			self:y(240):zoom(1):skewx(0.5)
			self:diffuse(ColorLightTone(PlayerColor(Player))):diffusetopedge(ColorDarkTone(PlayerColor(Player)))
		end;
		OnCommand=function(self) self:diffusealpha(0):sleep(0.14):linear(0.2):diffusealpha(1) end;
	};

	return t;
end;

function UpdateInternal3(self, Player)
	local pn = (Player == PLAYER_1) and 1 or 2;
	local frame = self:GetChild(string.format('P%uFrame', pn));
	local scroller = frame:GetChild('Scroller');
	local seltext = frame:GetChild('SelectedProfileText');
	local joinframe = frame:GetChild('JoinFrame');
	local smallframe = frame:GetChild('SmallFrame');
	local bigframe = frame:GetChild('BigFrame');

	if GAMESTATE:IsHumanPlayer(Player) then
		frame:visible(true);
		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			--using profile if any
			joinframe:visible(false);
			smallframe:visible(true);
			bigframe:visible(true);
			seltext:visible(true);
			scroller:visible(true);
			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(Player);
			if ind > 0 then
				scroller:SetDestinationItem(ind-1);
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(ind-1):GetDisplayName());
			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					scroller:SetDestinationItem(0);
					self:queuecommand('UpdateInternal2');
				else
					joinframe:visible(true);
					smallframe:visible(false);
					bigframe:visible(false);
					scroller:visible(false);
					seltext:settext('No profile');
				end;
			end;
		else
			--using card
			smallframe:visible(false);
			scroller:visible(false);
			seltext:settext('CARD');
			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0);
		end;
	else
		joinframe:visible(true);
		scroller:visible(false);
		seltext:visible(false);
		smallframe:visible(false);
		bigframe:visible(false);
	end;
end;

-- here's a (messy) fix for one player's selection ending the screen,
-- at least until this whole thing is rewritten to be... Not this
local ready = {}
local function AllPlayersReady()
	for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		if not ready[pn] then
			return false
		end
	end
	-- if it hasn't returned false by now, surely it must be true, right? RIGHT???
	return true
end

local t = Def.ActorFrame {

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	CodeMessageCommand = function(self, params)
		if params.Name == 'Start' or params.Name == 'Center' then
			MESSAGEMAN:Broadcast("StartButton");
			if not GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -1);
			else
				ready[params.PlayerNumber] = true
				if AllPlayersReady() then
					SCREENMAN:GetTopScreen():Finish();
				end
			end;
		end;
		if params.Name == 'Up' or params.Name == 'Up2' or params.Name == 'Up3' or params.Name == 'Up4' or params.Name == 'DownLeft' then
			-- Added a line to make sure the player can't fiddle around in the menu
			-- after they've already made a selection.
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) and not ready[params.PlayerNumber] then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 1 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind - 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Down' or params.Name == 'Down2' or params.Name == 'Down3' or params.Name == 'Down4' or params.Name == 'DownRight' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) and not ready[params.PlayerNumber] then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 0 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind + 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Back' then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel();
			else
				MESSAGEMAN:Broadcast("BackButton")
				-- Allow... erm... un-readying a player.
				if ready[params.PlayerNumber] then
					ready[params.PlayerNumber] = false
				else
					SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2);
				end
			end;
		end;
	end;

	PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	PlayerUnjoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	OnCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	UpdateInternal2Command=function(self)
		UpdateInternal3(self, PLAYER_1);
		UpdateInternal3(self, PLAYER_2);
	end;

	children = {
		LoadActorWithParams(THEME:GetPathG('', 'screenheader'), {}),
		Def.ActorFrame {
			Name = 'P1Frame';
			InitCommand=function(self) self:xy(SCREEN_CENTER_X-160,SCREEN_CENTER_Y):skewx(-0.5) end;
			OffCommand=function(self) self:easeinoutexpo(0.5):diffusealpha(0) end;
			children = LoadPlayerStuff(PLAYER_1);
		};
		Def.ActorFrame {
			Name = 'P2Frame';
			InitCommand=function(self) self:xy(SCREEN_CENTER_X+160,SCREEN_CENTER_Y):skewx(-0.5) end;
			OffCommand=function(self) self:easeinoutexpo(0.5):diffusealpha(0) end;
			children = LoadPlayerStuff(PLAYER_2);
		};
		-- sounds
		LoadActor( THEME:GetPathS("Common","start") )..{
			StartButtonMessageCommand=function(self) self:play() end;
		};
		LoadActor( THEME:GetPathS("Common","cancel") )..{
			BackButtonMessageCommand=function(self) self:play() end;
		};
		LoadActor( THEME:GetPathS("Common","value") )..{
			DirectionButtonMessageCommand=function(self) self:play() end;
		};
	};
};


return t .. {
	InitCommand = function(self)
		GAMESTATE:UpdateDiscordScreenInfo('Selecting Profile', '', 1)
	end
};
