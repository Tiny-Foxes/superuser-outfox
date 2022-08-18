-- We need this local function to override the usual behavior of it.
-- The whole point of CustomBranches is to load custom branches.
function SelectMusicOrCourse()
	if IsNetSMOnline() then
		return "ScreenNetSelectMusic"
	elseif GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourse"
	else
		return SelectMusicRedirect()
	end
end

CustomBranch = {
	SelectMusicOrCourse = SelectMusicOrCourse,
	StartGame = function()
		-- Check to see if there are 0 songs installed. Also make sure to check
		-- that the additional song count is also 0, because there is
		-- a possibility someone will use their existing StepMania simfile
		-- collection with sm-ssc via AdditionalFolders/AdditionalSongFolders.
		if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
			return "ScreenHowToInstallSongs"
		end
		if PROFILEMAN:GetNumLocalProfiles() > 0 then
			return "ScreenSelectProfile"
		else
			return "ScreenSelectPlayMode"
		end
	end,
	AfterProfileSave = function()
		if GAMESTATE:IsEventMode() then
			return SelectMusicOrCourse()
		elseif STATSMAN:GetCurStageStats():AllFailed() or
			GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() == 0 then
			return GameOverOrContinue()
		else
			return SelectMusicOrCourse()
		end
	end,
	AfterGameSet = function()
		if SCREENMAN:GetTopScreen():GetName():find('SelectMusic') then
			return SelectMusicRedirect()
		else
			return 'ScreenTitleMenu'
		end
	end,
}

function SelectMusicRedirect()
	return 'OFSelectMusic'
end
