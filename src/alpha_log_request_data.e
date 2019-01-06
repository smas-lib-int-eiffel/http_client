note
	description: "Summary description for {ALPHA_LOG_REQUEST_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ALPHA_LOG_REQUEST_DATA

inherit
	ALPHA_HTTP_CLIENT_REQUEST_DATA

create
	make

feature -- Initialization

	make (a_log_priority: STRING)
			--
		do
			log_priority := a_log_priority
		end

feature -- Access

	log_priority: STRING
			--

feature -- Output

	representation: STRING
			--
		local
			l_json: JSON_OBJECT
		do
			l_json := (create {JSON_FROM_EIFFEL_CONVERTER}).eiffel_to_json (Current)
			Result := l_json.representation
		end

end
