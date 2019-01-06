note
	description: "Alpha extension of DEFAULT_HTTP_CLIENT."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ALPHA_DEFAULT_HTTP_CLIENT

inherit
	DEFAULT_HTTP_CLIENT
		rename
			make as make_default
		end

create
	make

feature -- Initialization

	make (a_configuration: like configuration)
			-- Create a new http client.
		do
			make_default
			configuration := a_configuration
			session := new_session (configuration.versioned_authority)
			session.set_is_insecure (True)		-- This is to overcome security checks for TLS/SSL certificates.
		end

feature -- Access

	configuration: ALPHA_CFG_TCP_IP
			--

	Logger: ALPHA_HTTP_CLIENT_LOG_FACILITY
			--
		once
			create Result
		end

feature -- Basic operations

	Url_encoded_context: ALPHA_HTTP_CLIENT_REQUEST_CONTEXT
			-- Context with Url-encoded as content type
		once
			create Result.make
			Result.add_header ("Content-Type", "application/x-www-form-urlencoded")
		end

	Json_context: ALPHA_HTTP_CLIENT_REQUEST_CONTEXT
			-- Context with json as content type
		once
			create Result.make
			Result.add_header ("Content-Type", "application/json")
		end

	send_get_request (a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send GET request based on `a_path' and `ctx'.
			-- Make result available in `last_response'.
		do
			if attached ctx as la_ctx and then attached data as la_data then
				la_ctx.add_query_parameters ((create {ALPHA_NAME_VALUE_PAIR_CONVERTER}).to_key_value_pairs (la_data, Void))
			end
			send_request (Request_method_get, a_path, ctx, Void)
		end

	send_patch_request (a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send PATCH request based on `a_path' and `ctx'.
			-- Make result available in `last_response'.
		do
			send_request_with_data (Request_method_patch, a_path, ctx, data)
		end

	send_put_request (a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send PATCH request based on `a_path' and `ctx'.
			-- Make result available in `last_response'.
		do
			send_request_with_data (Request_method_put, a_path, ctx, data)
		end

	send_post_request (a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send POST request based on `a_path' and `ctx'.
			-- Make result available in `last_response'.
		do
			send_request_with_data (Request_method_post, a_path, ctx, data)
		end

	send_delete_request (a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send DELETE request based on `a_path' and `ctx'.
		do
			send_request_with_data (Request_method_delete, a_path, ctx, data)
		end

feature -- Access

	session: HTTP_CLIENT_SESSION
			--

	last_response: detachable HTTP_CLIENT_RESPONSE
			-- Result of last sent request

	last_response_ok: BOOLEAN
			-- True, when the last response has a positive result.
		do
			if attached last_response as la_last_response and then
			   not la_last_response.error_occurred and then
			   (la_last_response.status >= 200 and la_last_response.status < 300) then
				Result := True
			end
		end

feature {NONE} -- Implementation

	send_request_with_data (method: INTEGER; a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable ALPHA_HTTP_CLIENT_REQUEST_DATA)
			-- Send request based on `method', `a_path' and `ctx', with input `data'	
			-- Make result available in `last_response'.
		local
			l_data: STRING
		do
			if attached data as la_data then
				l_data := la_data.representation
			end
			send_request (method, a_path, ctx, l_data)
		end

	send_request (method: INTEGER; a_path: READABLE_STRING_8; ctx: detachable ALPHA_HTTP_CLIENT_REQUEST_CONTEXT; data: detachable STRING)
			-- Send request based on `method', `a_path' and `ctx', with input `data'	
			-- Make result available in `last_response'.
		do
			logger.log_request (Request_method_name (method), session.base_url  + a_path)
			if session.is_available then
				inspect
					method
				when Request_method_get then
					last_response := session.get (a_path, ctx)
				when Request_method_post then
					last_response := session.post (a_path, ctx, data)
				when Request_method_patch then
					last_response := session.patch (a_path, ctx, data)
				when Request_method_put then
					last_response := session.put (a_path, ctx, data)
				when request_method_delete then
					--last_response := session.delete_with_data (a_path, ctx, data)
				else
					last_response := Void
				end
				if attached last_response as la_response then
					if not last_response_ok and then attached la_response.error_message as la_message then
						Logger.log_error_occurred (la_message)
					end
				end
			end
		end

	json_response: detachable JSON_OBJECT
			-- Json object parsed from `response'
		local
			json: EJSON
			l_json_parser: JSON_PARSER
		do
			check
				attached last_response as la_response and then not la_response.error_occurred
			then
				if attached la_response.body as la_body and then not la_body.is_empty then
					create json
					create l_json_parser.make_with_string (la_body)
					l_json_parser.parse_content
					if l_json_parser.is_parsed then
						Result := l_json_parser.parsed_json_object
					end
				end
			end
			if not attached Result then
				logger.log_no_valid_body
			end
		end

feature {NONE} -- Constants

	Request_method_get: INTEGER = 1
			-- GET method

	Request_method_post: INTEGER = 2
			-- POST method

	Request_method_put: INTEGER = 3
			-- PUT method

	Request_method_patch: INTEGER = 4
			-- PATCH method

	Request_method_delete: INTEGER = 5
			-- DELETE method

	request_method_name (a_request_method: INTEGER): STRING
			--
		do
			inspect a_request_method
			when Request_method_get then
				Result := "GET"
			when Request_method_post then
				Result := "POST"
			when Request_method_put then
				Result := "PUT"
			when Request_method_patch then
				Result := "PATCH"
			when Request_method_delete then
				Result := "DELETE"
			else
				Result := "UNKNOWN"
			end
		end

end -- class ALPHA_DEFAULT_HTTP_CLIENT
