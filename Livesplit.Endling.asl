// Endling: Extinction is forever autosplitter for Livesplit usage
// Requires the LivesplitHelper mod !
//
// written by JP_dev
// Discord: JP#8135
// Twitch: twitch.tv/jp_dev
//

state("Endling-Win64-Shipping") {}

init
{
	const string MagicString = "ENDLINGLIVESPLIT";

	byte[] magicBytes = Encoding.UTF8.GetBytes(MagicString);
	var scanTarget = new SigScanTarget(magicBytes.Length, magicBytes);

	var module = modules.First(m => m.ModuleName == "LivesplitHelperMod.dll");
	print("------------------------ MODULE FOUND ! ------------------------");

	var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);
	vars.AutoSplitterData = scanner.ScanAll(scanTarget).First(p => p != IntPtr.Zero);
	print("------------------------ SIGNATURE FOUND ! ------------------------");
}

update
{
	IntPtr aslData = vars.AutoSplitterData;

	current.RunStarted     = game.ReadValue<int>(aslData + 0x0);
	current.ShelterId      = game.ReadValue<int>(aslData + 0x4);
	current.CreditsPlaying = game.ReadValue<int>(aslData + 0x8);
	current.Loading        = game.ReadValue<int>(aslData + 0xC);
}

start
{
	return old.RunStarted != 1 && current.RunStarted == 1;
}

split
{
	return old.ShelterId != current.ShelterId
		|| old.CreditsPlaying != 1 && current.CreditsPlaying == 1;
}

reset
{
	return old.RunStarted == 1 && current.RunStarted != 1;
}

isLoading
{
	return current.Loading == 1;
}
