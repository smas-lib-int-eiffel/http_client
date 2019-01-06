note
	description: "Summary description for {ALPHA_HTTP_CLIENT_REQUEST_CONTEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ALPHA_HTTP_CLIENT_REQUEST_CONTEXT

inherit
	HTTP_CLIENT_REQUEST_CONTEXT

create
	make

feature -- Element change

	add_query_parameters (parameters: LIST [TUPLE [STRING, STRING]])
			--
		do
			across
				parameters as list
			loop
				if attached {STRING} list.item [1] as la_key and then attached {STRING} list.item [2] as la_value then
					add_query_parameter (la_key, la_value)
				end
			end
		end

end
