package org.codedefenders.singleplayer;

import org.codedefenders.*;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import static org.codedefenders.Constants.AI_DIR;
import static org.codedefenders.Constants.F_SEP;

public class MajorMaker {

	private String cutTitle;
	private int cId;
	private GameClass cut;
	Game dGame;

	public MajorMaker(int classId, Game dummyGame) {
		cId = classId;
		cut = DatabaseAccess.getClassForKey("Class_ID", cId);
		cutTitle = cut.getBaseName();
		dGame = dummyGame;
	}

	public boolean createMutants() {
		AntRunner.generateMutantsFromCUT(cutTitle);

		File cutFile = new File(cut.javaFile);
		List<String> cutLines = FileManager.readLines(cutFile.toPath());

		for (String info : getMutantList()) {
			//Each mutant in mutants log.

			//Get required mutant info.
			String[] splitInfo = info.split(":");
			/*
			0 = Mutant's id
			1 = Name of mutation operator
			2 = Original operator symbol
			3 = New operator symbol
			4 = Full name of mutated method
			5 = Line number of CUT
			6 = 'from' |==> 'to'  (<NO-OP> means empty string)
			 */
			//Only really need values 5 and 6.
			//Use replace option?
			int lineNum = Integer.parseInt(splitInfo[5]);
			String[] beforeAfter = splitInfo[6].split(Pattern.quote(" |==> ")); //Before = 0, After = 1

			MutantPatch mP = new MutantPatch(lineNum, beforeAfter);

			List<String> newLines = doPatch(cutLines, mP);
			String mText = "";
			for (String l : newLines) {
				mText += l + "\n";
			}

			//Write to java file in next available folder.
			//Compile file.
			//Create & insert mutant.
		}


		return true;
	}

	/**
	 * Modify a list of strings from a class to have a mutant.
	 * @param lines original class's lines.
	 * @param patch the mutant's patch information.
	 * @return the new list of lines.
	 */
	private List<String> doPatch(List<String> lines, MutantPatch patch) {
		//Copy contents of original lines.
		List<String> newLines = new ArrayList<String>(lines);
		String l = newLines.get(patch.getLineNum() - 1);
		String newLine = l.replaceFirst(patch.getOriginal(), patch.getReplacement().replace("QE", ""));
		newLines.set(patch.getLineNum() - 1, newLine);
		return newLines;
	}

	private List<String> getMutantList() {
		String loc = AI_DIR + F_SEP + "mutants" + F_SEP + cutTitle + ".log";
		File f = new File(loc);
		List<String> l = FileManager.readLines(f.toPath());
		//TODO: Handle errors.
		return l;
	}
}
