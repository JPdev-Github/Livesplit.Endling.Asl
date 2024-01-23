// Endling: Extinction is forever autosplitter for Livesplit usage
// Requires the LivesplitHelper mod !
// 
// written by JP_dev
// Discord: JP#8135
// Twitch: twitch.tv/jp_dev
//

state("Endling-Win64-Shipping") {}

startup {
	vars.scanTarget = new SigScanTarget(16, "45 4E 44 4C 49 4E 47 4C 49 56 45 53 50 4C 49 54");
	vars.InitComplete = false;
	vars.MaxShelterId = 0;
}

init
{
	IntPtr ptr = IntPtr.Zero;

	var module = modules.First(m => m.ModuleName == "LivesplitHelperMod.dll");

	print("------------------------ MODULE FOUND ! ------------------------");
	// Prepare scanner 
	var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);
	ptr = scanner.Scan(vars.scanTarget);
	// if something was found, leave the loop
	if (ptr != IntPtr.Zero) {
		print("------------------------ SIGNATURE FOUND ! ------------------------");
		vars.watchers = new MemoryWatcherList();
		vars.watchers.Add(new MemoryWatcher<Int32>(new DeepPointer(ptr)) {Name = "RunStarted"});
		vars.watchers.Add(new MemoryWatcher<Int32>(new DeepPointer(ptr+4)) {Name = "ShelterId"});
		vars.watchers.Add(new MemoryWatcher<Int32>(new DeepPointer(ptr+8)) {Name = "CreditsPlaying"});
		vars.watchers.Add(new MemoryWatcher<Int32>(new DeepPointer(ptr+12)) {Name = "Loading"});
		vars.InitComplete = true;
		return true;
	}
}

update
{
	if (!(vars.InitComplete))
	        return false;
	vars.watchers.UpdateAll(game);
}

start
{
	var bStart = (vars.watchers["RunStarted"].Changed) &&
		(vars.watchers["RunStarted"].Current == 1);
	if (bStart) {
		vars.MaxShelterId = 0;
	}
	return bStart;
}

split
{
	var b = (vars.watchers["ShelterId"].Changed && (vars.watchers["ShelterId"].Current > vars.MaxShelterId))
	|| ((vars.watchers["CreditsPlaying"].Changed) && (vars.watchers["CreditsPlaying"].Current == 1));
	if (b) {
		print("Changing vars.MaxShelterId from " + vars.MaxShelterId + " to " + vars.watchers["ShelterId"].Current);
		vars.MaxShelterId = vars.watchers["ShelterId"].Current;
	}
	return b;
}

reset
{
	return (vars.watchers["RunStarted"].Changed) &&
		(vars.watchers["RunStarted"].Current == 1);
}

isLoading
{
	return (vars.watchers["Loading"].Current == 1);
}
