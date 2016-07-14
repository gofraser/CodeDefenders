package org.codedefenders;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

/**
 * Created by jmr on 13/07/2016.
 */
public abstract class AbstractGame {
	protected static final Logger logger = LoggerFactory.getLogger(Game.class);
	protected int id;
	protected int classId;
	protected State state;
	protected Level level;
	protected Mode mode;

	public int getId() {
		return id;
	}

	public int getClassId() {
		return classId;
	}

	public String getClassName() {
		return DatabaseAccess.getClassForKey("Class_ID", classId).getName();
	}

	public GameClass getCUT() {
		return DatabaseAccess.getClassForKey("Class_ID", classId);
	}

	public State getState() {
		return state;
	}

	public void setState(State s) {
		state = s;
	}

	public Level getLevel() {
		return this.level;
	}

	public void setLevel(Level level) {
		this.level = level;
	}

	public Mode getMode() {
		return this.mode;
	}

	protected void setMode(Mode newMode) { this.mode = newMode; }

	// TODO:
	// public abstract ArrayList<Mutant> getMutants();

	public abstract ArrayList<Test> getTests();

	public abstract boolean addPlayer(int userId, Role role);

	public Role getRole(int userId){
		return DatabaseAccess.getRole(userId, getId());
	}

	public abstract boolean insert();

	public abstract boolean update();

	public boolean runStatement(String sql) {

		Connection conn = null;
		Statement stmt = null;

		System.out.println(sql);

		// Attempt to insert game info into database
		try {
			conn = DatabaseAccess.getConnection();

			stmt = conn.createStatement();
			stmt.execute(sql, Statement.RETURN_GENERATED_KEYS);

			ResultSet rs = stmt.getGeneratedKeys();

			if (rs.next()) {
				rs.getInt(1);
				stmt.close();
				conn.close();
				return true;
			}

		} catch (SQLException se) {
			System.out.println(se);
			//Handle errors for JDBC
		} catch (Exception e) {
			System.out.println(e);
			//Handle errors for Class.forName
		} finally {
			//finally block used to close resources
			try {
				if (stmt != null)
					stmt.close();
			} catch (SQLException se2) {
			}// nothing we can do

			try {
				if (conn != null)
					conn.close();
			} catch (SQLException se) {
				System.out.println(se);
			}//end finally try
		} //end try

		return false;
	}

	public enum State { CREATED, ACTIVE, FINISHED }

	public enum Level { EASY, MEDIUM, HARD }

	public enum Mode { SINGLE, DUEL, PARTY, UTESTING }
}