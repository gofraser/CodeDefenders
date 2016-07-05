package org.codedefenders.singleplayer;

import org.codedefenders.*;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.crypto.Data;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static org.codedefenders.Constants.*;

/**
 * @author Ben Clegg
 * An AI defender. Uses tests generated by EvoSuite to kill mutants.
 */
public class AiDefender extends AiPlayer {

	public AiDefender(Game g) {
		super(g);
		role = Game.Role.DEFENDER;
	}
	public boolean turnHard() {
		//Run all generated tests for class.
		if(game.getTests().isEmpty()) {
			//Add test suite to game if it isn't present.
			GameManager gm = new GameManager();
			Test newTest = gm.submitAiTestFullSuite(game);
			newTest.insert();
			//Run the tests on existing mutants.
			MutationTester.runTestOnAllMutants(game, newTest, new ArrayList<String>());

		}
		//Do nothing else, test is automatically re-run on new mutants by GameManager.
		//TODO: Add equivalence check.
		//Call equivalent only if test suite passes on mutant.
		return true;
	}

	public boolean turnMedium() {
		//Choose all tests which cover modified line(s)?
		//Perhaps just 1 or 2?
		//Perhaps higher chance of equivalence call? May happen due to weaker testing.
		return turnHard();
	}

	public boolean turnEasy() {
		//Choose a random test which covers the modified line(s)?
		//Perhaps just a random test?
		//Perhaps higher chance of equivalence call? May happen due to weaker testing.
		try {
			IndexContents ind = new IndexContents(game.getClassName());

			int tNum = selectTest(GenerationMethod.RANDOM, ind);
			try {
				useTestFromSuite(tNum, ind);
			} catch (IOException e) {
				e.printStackTrace();
				return false;
			}
		} catch (Exception e) {
			//Assume no more choices remain.
			//Do nothing.
		}

		return true;
	}

	private int selectTest(GenerationMethod strategy, IndexContents indexCon) throws Exception {

		ArrayList<Integer> usedTests = DatabaseAccess.getUsedAiTestsForGame(game);
		int totalTests = indexCon.getNumTests();
		Exception e = new Exception("No choices remain.");

		if(usedTests.size() == totalTests) {
			throw e;
		}
		int t = -1;

		Game dummyGame = DatabaseAccess.getGameForKey("Game_ID", indexCon.getDummyGameId());
		ArrayList<Test> origTests = dummyGame.getTests();

		for (int i = 0; i <= 3; i++) {
			//Try to get test by default strategy.
			int n = 0;
			if (strategy.equals(GenerationMethod.RANDOM)) {
				n = (int) Math.floor(Math.random() * totalTests);
				//0 -> totalTests - 1.
			}
			//TODO: Other strategies.

			//Get original test from dummy game's list of tests.
			Test origT = origTests.get(n);
			t = origT.getId();

			if ((!usedTests.contains(t)) && (t != -1)) {
				//Strategy found an unused test.
				return t;
			}
		}

		//If standard strategy fails, choose first non-selected test.
		for (int x = 0; x < totalTests; x++) {
			if(!usedTests.contains(x)) {
				//Unused test found.
				return x;
			}
		}

		//Something went wrong.
		throw e;
	}

	private void useTestFromSuite(int origTestNum, IndexContents indexCon) throws IOException {
		Game dummyGame = DatabaseAccess.getGameForKey("Game_ID", indexCon.getDummyGameId());
		ArrayList<Test> origTests = dummyGame.getTests();

		Test origT = null;

		for (Test t : origTests) {
			if(t.getId() == origTestNum) {
				origT = t;
				break;
			}
		}

		if(origT != null) {
			String jFile = origT.getFolder() + F_SEP + "Test" + dummyGame.getClassName() + JAVA_SOURCE_EXT;
			String cFile = origT.getFolder() + F_SEP + "Test" + dummyGame.getClassName() + JAVA_CLASS_EXT;
			Test t = new Test(game.getId(), jFile, cFile, 1);
			t.insert();
			t.update();
			TargetExecution newExec = new TargetExecution(t.getId(), 0, TargetExecution.Target.COMPILE_TEST, "SUCCESS", null);
			newExec.insert();
			ArrayList<String> messages = new ArrayList<String>();
			MutationTester.runTestOnAllMutants(game, t, messages);
			DatabaseAccess.setAiTestAsUsed(origTestNum, game);
			File dir = new File(origT.getFolder());
			AntRunner.testOriginal(dir, t);
			game.update();
		}
	}

}

class IndexContents {

	private ArrayList<Integer> testIds;
	private int dummyGameId;
	private int numTests;

	public IndexContents(String className) {
		testIds = new ArrayList<Integer>();
		dummyGameId = -1;
		numTests = -1;
		//Parse the test index file of a given class.
		try {
			File f = new File(AI_DIR + F_SEP + "tests" + F_SEP +
					className + F_SEP + className + TEST_INFO_EXT);
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuild = dbFactory.newDocumentBuilder();
			Document d = dBuild.parse(f);

			d.getDocumentElement().normalize();

			NodeList tIdNodes = d.getElementsByTagName("test");
			for (int i = 0; i < tIdNodes.getLength(); i++) {
				Node tIdNode = tIdNodes.item(i);
				testIds.add(Integer.parseInt(tIdNode.getTextContent()));
			}
			NodeList q = d.getElementsByTagName("quantity");
			numTests = Integer.parseInt(q.item(0).getTextContent());
			NodeList g = d.getElementsByTagName("dummygame");
			dummyGameId = Integer.parseInt(g.item(0).getTextContent());

		} catch (Exception e) {
			e.printStackTrace();
			//TODO: Handle errors.
		}


	}

	public ArrayList<Integer> getTestIds() {
		return testIds;
	}

	public int getNumTests() {
		return numTests;
	}

	public int getDummyGameId() {
		return dummyGameId;
	}

}