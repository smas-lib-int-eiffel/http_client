note
	description: "Data to be sent with an HTTP_REQUEST"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ALPHA_HTTP_CLIENT_REQUEST_DATA

feature -- Output

	representation: STRING
			-- Used as data when sending a request
		deferred
		end

end -- class ALPHA_HTTP_CLIENT_REQUEST_DATA
