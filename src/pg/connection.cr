class PG::Connection < ::DB::Connection
  protected getter connection

  def initialize(database)
    super
    conn_info = PQ::ConnInfo.new(database.uri)
    @connection = PQ::Connection.new(conn_info)
    @connection.connect
  end

  def build_statement(query)
    Statement.new(self, query)
  end

  def version
    query = "SELECT ver[1]::int AS major, ver[2]::int AS minor, ver[3]::int AS patch
               FROM regexp_matches(version(), 'PostgreSQL (\\d+)\\.(\\d+)\\.(\\d+)') ver"
    major, minor, patch = query_one query, &.read(Int32, Int32, Int32)
    {major: major, minor: minor, patch: patch}
  end

  protected def do_close
    @connection.close
  end
end

# require "../pq/*"

# module PG
#   class Connection
#     # Connect with all default paramaters.
#     #
#     # This attempts to locate a Unix socket, then falls back to localhost. It
#     # uses your current username as both the user and database.
#     def initialize
#       initialize(PQ::ConnInfo.new)
#     end

#     # Connect with a `PQ::ConnInfo`.
#     #
#     # If you are making a lot of connections to the same database, it may be
#     # useful to reuse the `PQ::ConnInfo` to avoid reparsing the connection
#     # every time. All other initialization methods end up here.
#     def initialize(conninfo : PQ::ConnInfo)
#       @pq_conn = PQ::Connection.new(conninfo)
#       @pq_conn.connect
#       exec("SET extra_float_digits = 3")
#     end

#     # Connect with a `"postgres://"` URL or a Postgres "conninfo" string.
#     #
#     #     PG::Connection.new("postgres://user:passs@somehost.com/mydatabase?sslmode=require")
#     def initialize(conninfo : String)
#       initialize PQ::ConnInfo.from_conninfo_string(conninfo)
#     end

#     # Connect to the server with values of Hash.
#     #
#     #     PG::Connection.new({ "host": "localhost", "user": "postgres",
#     #       "password":"password", "dbname": "test_db", "port": "5432" })
#     def initialize(params : Hash)
#       initialize PQ::ConnInfo.new(params)
#     end

#     # Set the callback block for notices and errors.
#     def on_notice(&on_notice_proc : PQ::Notice ->)
#       @pq_conn.notice_handler = on_notice_proc
#     end

#     # Set the callback block for notifications from Listen/Notify.
#     def on_notification(&on_notification_proc : PQ::Notification ->)
#       @pq_conn.notification_handler = on_notification_proc
#     end

#     # :nodoc:
#     def listen
#       spawn { @pq_conn.read_async_frame_loop }
#     end

#     # Execute an untyped query and store the results in memory.
#     def exec(query : String) : Result
#       exec([] of PG::PGValue, query, [] of PG::PGValue)
#     end

#     # Execute an untyped query with parameters and store the results in memory.
#     def exec(query : String, params) : Result
#       exec([] of PG::PGValue, query, params)
#     end

#     # Execute a typed query and store the results in memory.
#     def exec(types, query : String) : Result
#       exec(types, query, [] of PG::PGValue)
#     end

#     # Execute a typed query with parameters and store the results in memory.
#     def exec(types, query : String, params) : Result
#       @pq_conn.synchronize do
#         Result.new(types, extended_query(query, params))
#       end
#     end

#     # Execute an untyped query and stream the results.
#     def exec(query : String) : Nil
#       exec([] of PG::PGValue, query, [] of PG::PGValue) do |row, fields|
#         yield row, fields
#       end
#     end

#     # Execute an untyped query with parameters and stream the results.
#     def exec(query : String, params) : Nil
#       exec([] of PG::PGValue, query, params) do |row, fields|
#         yield row, fields
#       end
#     end

#     # Execute an typed query and stream the results.
#     def exec(types, query : String) : Nil
#       exec(types, query, [] of PG::PGValue) do |row, fields|
#         yield row, fields
#       end
#     end

#     # Execute an typed query with parameters and stream the results.
#     def exec(types, query : String, params) : Nil
#       @pq_conn.synchronize do
#         Result.stream(types, extended_query(query, params)) do |row, fields|
#           yield row, fields
#         end
#       end
#     end

#     # Execute several statements. No results are returned.
#     def exec_all(query : String) : Nil
#       PQ::SimpleQuery.new(@pq_conn, query)
#       nil
#     end

#     # :nodoc:
#     def finalize
#       close
#     end

#   class ListenConnection
#     def initialize(conninfo, *channels : String, &blk : PQ::Notification ->)
#       @pg_conn = Connection.new(conninfo)
#       @pg_conn.on_notification(&blk)
#       channels.each {|c| @pg_conn.exec "LISTEN #{@pg_conn.escape_identifier c}" }
#       @pg_conn.listen
#     end

#     # Close the connection.
#     def close
#       @pg_conn.close
#     end
#   end
# end
