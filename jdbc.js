var postgresql = {
	db_type: "postgresql",
	host: "127.0.0.1",
	port: 5432,
	user : 'postgres',
	password : 'abc123',
	database: "qv",
	max: 30,
	idleTimeoutMillis: 60000
};
exports.db = postgresql;
