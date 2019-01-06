note
	description: "Summary description for {ALPHA_HTTP_CLIENT_LOG_FACILITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ALPHA_HTTP_CLIENT_LOG_FACILITY

inherit
	SHARED_LOG_FACILITY
		redefine
			write_error,
			write_information
		end

feature -- Basic operations

	log_session_not_available
			-- Log that the session is not availabe.
		do
			write_error ("session not available")
	end

	log_error_occurred (an_error_message: STRING)
			-- Log that an error occurred, specified by `an_error_message'.
		do
			write_error ("error occurred (" + an_error_message + ").")
	end

	log_no_valid_body
			-- Log that the http response contains no (valid) body.
		do
			write_error ("no valid body in http response")
		end

	log_no_valid_resource
			-- Log that the http response contains an invalid resource.
		do
			write_error ("no valid resource in http response")
		end

	log_request (a_method: STRING; a_path: STRING)
			-- Log that a request with `a_method' is sent to `a_path'.
		do
			write_information ("Send " + a_method + " request to URI -> " + a_path)
		end

feature -- Output

	write_error (msg: STRING)
			-- <Precursor>
		do
			Precursor (caption + msg)
		end

	write_information (msg: STRING)
			-- <Precursor>
		do
			Precursor (caption + msg)
		end

feature -- Implementation

	caption: STRING
			--
		do
			Result := "HTTP client"
			if attached client_name as la_client_name then
				Result.append (" (" + la_client_name + ")")
			end
			Result.append (": ")
		end

	client_name: detachable STRING
			--

end
