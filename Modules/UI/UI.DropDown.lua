return function( width, height, xpos, ypos, list, currentitem, peritemaction, player, requiresredirect )
    GAMESTATE:Env()["OpenedDropdown"] = false
    local inputsystem

    local CheckDropdownState = function()
        local state = false

        if player then
            state = GAMESTATE:Env()["OpenedDropdown"..player]
        else
            state = GAMESTATE:Env()["OpenedDropdown"]
        end

        return state
    end

    local yspacing = 32
    local indexcur = 1
    local tempcur = indexcur
    local t = Def.ActorFrame{
        InitCommand=function(self)
            self.isopen = false

            -- If we do have a player being assigned, but does not exist yet, then block input from it,
            -- and wait externally for it to arrive.
            if player then
                self.eatinput = not GAMESTATE:IsPlayerEnabled(player)
            end

            self:playcommand("ToggleRedirect", { Mode = false })
            for k,v in pairs( self:GetChildren() ) do
                v:xy( xpos, ypos )
            end
            -- self:GetChild("ChildrenList"):playcommand("ShowMenu")
            indexcur = currentitem(self, list, player)
        end,
        OnCommand=function(self)
            inputsystem = LoadModule("Lua.InputSystem.lua")(self)
            SCREENMAN:GetTopScreen():AddInputCallback( inputsystem )
            self.eatinput = true
        end,
        OffCommand=function(self)
            SCREENMAN:GetTopScreen():RemoveInputCallback( inputsystem )
        end,
        ToggleRedirectCommand=function(self,event)
            -- If there's no player specified, then both player's inputs will be taken away,
            -- as it takes the assumption of only being one individual controlling input.
            
            if player then
                GAMESTATE:Env()["OpenedDropdown"..player] = event.Mode
            else
                GAMESTATE:Env()["OpenedDropdown"] = event.Mode
            end

            if requiresredirect then
                if player then
                    SCREENMAN:set_input_redirected( player , event.Mode )
                else
                    for k,v in pairs( PlayerNumber ) do
                        SCREENMAN:set_input_redirected( v , event.Mode )
                    end
                end
            end

            -- This will toggle the inputfilter controlled in this module.
            self.eatinput = not event.Mode

            -- This will eat input from whatever inputfilter loaded from
            -- the actorframe this module was loaded from.
            self:GetParent().eatinput = event.Mode
        end,

        StartCommand=function(self,param)
            if player and self.pn ~= player then return end
            if self.isopen then
                self.isopen = false

                self:GetChild("ChildrenList"):playcommand("ShowMenu")
                self:GetChild("LabelText"):settext( self:GetChild("ChildrenList"):GetChild(indexcur).itemname )
                if self:GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                    self:GetChild("ObjectHolder"):visible(true):SetTarget( self:GetChild("ChildrenList"):GetChild(indexcur):GetChild(""):GetChild("Icon") )
                    self:GetChild("LabelText"):x( xpos - width*.3 ):maxwidth( width*.6 )
                else
                    self:GetChild("ObjectHolder"):visible(false)
                    self:GetChild("LabelText"):x( xpos - width*.425 ):maxwidth( width*.6 )
                end

                if not param.Nullify then
                    if peritemaction then
                        peritemaction( self:GetChild("ChildrenList"):GetChild(indexcur):GetChild("Click") , list, indexcur, player)
                    end
                end

                -- It's time to leave the dropdown menu, and return input to the player,
                -- otherwise, it wouldn't be fair.
                self:playcommand("ToggleRedirect",{ Mode = false })
            end
        end,
        StoreInfoCommand=function(self)
            tempcur = indexcur
        end,
        BackCommand=function(self)
            -- Reset the value to what it was originally.
            indexcur = tempcur

            self:playcommand("Start",{Nullify = true})
        end,
        MenuUpCommand=function(self) self:playcommand("Move", {-1} ) end,
	    MenuDownCommand=function(self) self:playcommand("Move", {1} ) end,
        MenuLeftCommand=function(self) self:playcommand("Move", {-1} ) end,
	    MenuRightCommand=function(self) self:playcommand("Move", {1} ) end,
        MoveCommand=function(self,param)
            if player and self.pn ~= player then return end
            local newval = indexcur + param[1]
    
            if newval < 1 then newval = #list end
            if newval > #list then newval = 1 end
            
            indexcur = newval

            self:GetChild("ChildrenList"):playcommand("ShowMenu")

            if not param[2] then
                -- self:GetChild("SoundChange"):play()
            end
        end,
    }

    local maxypos = yspacing * #list

    local ListActorFrame = Def.ActorFrame{
        Name="ChildrenList",
        InitCommand=function(self)
            self.pos = 0
            for k,v in pairs( list ) do
                self:GetChild(k):y(height):diffusealpha( self:GetParent().isopen and 1 or 0 )
            end
        end,
        ShowMenuCommand=function(self)
            if #list > 15 then
                self.pos = yspacing * (indexcur-1)
            end
            
            self:GetParent():GetChild("BG"):stoptweening()
            for k,v in pairs( list ) do
                self:GetChild(k):stoptweening():easeoutquint(0.5)
                :y( self:GetParent().isopen and (8 + (yspacing * (k))) or height )
                :diffusealpha( self:GetParent().isopen and 1 or 0 )
            end
            self:GetParent():GetChild("Click").eatinput = self:GetParent().isopen
            
            -- Elements from the scroller itself.
            self:GetChild("BGPlane"):stoptweening():easeoutquint(0.5):zoomy( self:GetParent().isopen and (maxypos + yspacing) or 0 )
            self:GetChild("BGPlane2"):stoptweening():easeoutquint(0.5):zoomy( self:GetParent().isopen and (maxypos + yspacing - 8) or 0 )
            self:GetChild("Highlight"):stoptweening():easeoutquint(0.5):diffusealpha( self:GetParent().isopen and 0.5 or 0 )
            :y( -8 + (yspacing * (indexcur)) )

            -- Parent actors from the scroller.
            self:GetParent():GetChild("LabelText"):finishtweening():easeoutquint(0.125):y( self:GetParent().isopen and (ypos-self.pos) or ypos )
            self:GetParent():GetChild("ObjectHolder"):finishtweening():easeoutquint(0.125):y( self:GetParent().isopen and (ypos-self.pos) or ypos )
            self:GetParent():GetChild("BG"):finishtweening():easeoutquint(0.125):y( self:GetParent().isopen and (ypos-self.pos) or ypos )
            self:GetParent():GetChild("Overflow"):finishtweening():easeoutquint(0.125):diffusealpha( self:GetParent().isopen and 0 or 1 )
            self:playcommand("MoveArea",{ loc =  0 } )
        end,
        MoveAreaCommand=function(self,param)
            if not self:GetParent().isopen then return end
            if (#list < 15 and ((ypos + maxypos) < SCREEN_BOTTOM)) then return end
            self.pos = self.pos + param.loc
    
            if self.pos < 0 then
                self.pos = 0
            end
    
            if self.pos > (maxypos - yspacing) then
                self.pos = (maxypos - yspacing)
            end
    
            self:hurrytweening(0.75):decelerate(0.05):y( ypos-self.pos )
            self:GetParent():GetChild("BG"):hurrytweening(0.75):easeoutquint(0.05):y( ypos-self.pos )
            self:GetParent():GetChild("LabelText"):hurrytweening(0.75):easeoutquint(0.05):y( ypos-self.pos )
            self:GetParent():GetChild("ObjectHolder"):hurrytweening(0.75):easeoutquint(0.05):y( ypos-self.pos )
        end,
        MouseWheelDownMessageCommand=function(self)
            self:playcommand("MoveArea",{ loc =  -5} )
        end,
        MouseWheelUpMessageCommand=function(self)
            self:playcommand("MoveArea",{ loc =  5} )
        end,
        ResetRedCommand=function(self)
            self:GetParent():playcommand("ToggleRedirect",{ Mode = false })
        end,
        -- When exiting, force the ToggleRedirect command to ensure that controls are eaten.
        OffCommand=function(self)
            self:GetParent():playcommand("ToggleRedirect",{ Mode = false })
        end,

        Def.Quad{
            Name="BGPlane",
            OnCommand=function(self)
                self:zoomto( width - 8, 0 ):valign(0):diffuse( GameColor.Custom["MenuButtonBorder"] )
            end
        },

        Def.Quad{
            Name="BGPlane2",
            OnCommand=function(self)
                self:zoomto( width - 12, 0 ):y(4):valign(0)
                :diffuse( ColorDarkTone( GameColor.Custom["MenuButtonGradient"] ) )
            end
        },

        Def.Quad{
            Name = "Highlight",
            OnCommand = function(self)
                self:zoomto( width - 12, yspacing ):valign(0)
                :y( yspacing * (indexcur-1) ):diffusealpha(0)
            end
        }
    }
    for k,v in pairs( list ) do
        local itemname,itemicon

        -- Items can either be a table, or a string. Check those cases.
        local temp = Def.ActorFrame{
            Name = k,
            InitCommand=function(self) self:y( 8 + (yspacing * k) ) end
        }

        if type(v) == "table" then
            itemname = v.Name or ""
            itemicon = v.Icon or nil

            -- if we do have icon, sanitise it's contents.
            if itemicon then
                -- If it's not an actortype, it might just be looking to apply a direct texture.
                if type(itemicon) ~= "table" then
                    itemicon = Def.Sprite{ Texture = itemicon }
                end
            end

            -- Add the main object
            temp[#temp+1] = Def.ActorFrame{
                (itemicon..{
                    Name = "Icon",
                    OnCommand=function(self)
                        self:zoom(
                            LoadModule("Lua.Resize.lua")(
                                self:GetZoomedWidth(),
                                self:GetZoomedHeight(),
                                width,
                                height - (v.Margin or 6)
                            )
                        ):x( -(width/2) + 32 )
                    end
                } or Def.Actor),
                Def.BitmapText{
                    Name = "Text",
                    Font = "Common Normal",
                    Text = itemname,
                    InitCommand=function(self)
                        self:halign( 0 ):x( -(width/2) + 60 ):maxwidth( width - 72 )
                    end
                },
            }
        else
            itemname = v
            -- Add the main object
            temp[#temp+1] = Def.BitmapText{
                Name = "Text",
                Font = "Common Normal",
                Text = itemname,
                InitCommand=function(self)
                    self:halign( 0 ):x( -(width/2) + 16 ):maxwidth( width - 30 )
                end
            }
        end

        -- Only the click area needs to be generated here to perform the placement.
        temp[#temp+1] = LoadModule( "UI/UI.ClickArea.lua" ){
			Width = width,
			Height = yspacing - 2,
			Action = function(self)
				-- After selecting an option, close the dropdown menu, and alert the manager
				-- that this is the new option.
				local rootlevel = self:GetParent():GetParent():GetParent()
				if rootlevel.isopen and CheckDropdownState() then
					rootlevel.isopen = false

					rootlevel:GetChild("ChildrenList"):playcommand("ShowMenu")
					rootlevel:GetChild("LabelText"):settext( itemname )
					indexcur = k
					if rootlevel:GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
						rootlevel:GetChild("ObjectHolder"):visible(true):SetTarget( rootlevel:GetChild("ChildrenList"):GetChild(indexcur):GetChild(""):GetChild("Icon") )
						rootlevel:GetChild("LabelText"):x( xpos - width*.3 ):maxwidth( width*.6 )
					else
						rootlevel:GetChild("ObjectHolder"):visible(false)
						rootlevel:GetChild("LabelText"):x( xpos - width*.425 ):maxwidth( width*.6 )
					end

					if peritemaction then
						peritemaction(self, list, k, player)
					end

					-- It's time to leave the dropdown menu, and return input to the player,
					-- otherwise, it wouldn't be fair.
					rootlevel:sleep(0.25):queuecommand("ResetRed")
				end
			end
		} .. { Name="Click" }

        temp.OnCommand=function(self) self.itemname = itemname end

        ListActorFrame[#ListActorFrame+1] = temp

    end
    t[#t+1] = ListActorFrame

    t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( width, height )..{ Name = "BG" }

    t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" ){
		Width = width,
		Height = height,
		Action = function(self)
			if not CheckDropdownState() then
				self:GetParent().isopen = not self:GetParent().isopen
				self:GetParent():GetChild("ChildrenList"):playcommand("ShowMenu")

				self:GetParent():playcommand("ToggleRedirect",{ Mode = true })
				-- Once the menu has been opened, input from the keyboard will be taken
				-- away to provide control to the dropdown menu's choices.

				-- This will disable the inputfilter controlled in this module.
				self:GetParent().eatinput = false
				
				-- Store the current value that the dropdown menu has.
				self:GetParent():playcommand("StoreInfo")

				-- This will eat input from whatever inputfilter loaded from
				-- the actorframe this module was loaded from.
				self:GetParent():GetParent():GetParent().eatinput = true
			end
		end,
		ActionUnclick = function(self)
			-- local rootlevel = self:GetParent():GetParent():GetParent()
			self:GetParent().eatinput = true
			if self:GetParent().isopen then
				self:GetParent().isopen = false
				self:GetParent():GetChild("ChildrenList"):playcommand("ShowMenu")

				-- It's time to leave the dropdown menu, and return input to the player,
				-- otherwise, it wouldn't be fair.
				self:GetParent():playcommand("ToggleRedirect",{ Mode = false })
			end
		end
	} .. { Name="Click" }

    t[#t+1] = Def.BitmapText{
        Name = "LabelText",
        Font = "Common Normal",
        OnCommand = function(self)
            self:halign(0):x( xpos - width*.425 )
            :maxwidth( width - self:GetParent():GetChild("Overflow"):GetZoomedWidth() - 6 )
            self:settext(
                type(list[indexcur]) == "table" and list[indexcur].Name or list[indexcur]
            )

            if self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                self:x( xpos - width*.2 ):maxwidth( width*.4 )
            end
        end
    }

    t[#t+1] = Def.ActorProxy{
        Name = "ObjectHolder",
        OnCommand = function(self)  
            self:x( xpos )
            if self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                self:SetTarget( self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild(""):GetChild("Icon") )
            end
        end
    }
    
    t[#t+1] = Def.Sprite{
        Name = "Overflow",
        Texture = THEME:GetPathG("MenuIcon","dropdown"),
        OnCommand = function(self)
            self:halign(1):x( xpos + width*.45 ):zoom(0.25)
        end
    }
    
    return t
end

--[[
	Copyright 2021 Jose Varela, Project OutFox

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]