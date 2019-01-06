note
	description: "Summary description for {KEY_VALUE_CONVERTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ALPHA_NAME_VALUE_PAIR_CONVERTER

inherit
	INTERNAL

feature -- Basic operation

	keep_void: BOOLEAN

	to_key_value_string (object: ANY; parent_name: detachable STRING): STRING
			-- Eiffel `object' converted to a key_value string
			--
		do
			create Result.make_empty
			across to_key_value_pairs (object, parent_name)
				 as list
			loop
				if attached {STRING} list.item [1] as la_key and then attached {STRING} list.item [2] as la_value then
					Result.append (la_key)
					Result.extend ('=')
					Result.append (la_value)
					Result.extend ('&')
				end
			end
			Result.prune_all_trailing ('&')
		end

	to_key_value_pairs (object: ANY; parent_name: detachable STRING): LINKED_LIST [TUPLE [STRING, STRING]]
			-- Eiffel `object' converted to key_value pairs
		local
			i, cnt: INTEGER
			l_prefix: STRING
			l_name: STRING
		do
			cnt := field_count (object)
			create Result.make
			from
				i := 1
			until
				i > cnt
			loop
				l_name := field_name (i, object)
				if attached parent_name as la_parent_name then
					l_name.prepend (la_parent_name + ".")
				end
				inspect
					field_type (i, object)
				when Boolean_type then
					Result.extend (key_value_pair (l_name, boolean_field (i, object)))
				when Integer_type then
					Result.extend (key_value_pair (l_name, integer_field (i, object)))
				when Natural_64_type then
					Result.extend (key_value_pair (l_name, natural_64_field (i, object)))
				when Real_type then
					Result.extend (key_value_pair (l_name, real_field (i, object)))
				when Reference_type then
					if attached reference_field (i, object) as la_reference then
						if attached {STRING} la_reference then
							Result.extend (key_value_pair (l_name, la_reference))
						else
							if attached {ALPHA_NAME_VALUE_PAIRABLE} la_reference as la_object and then la_object.use_class_name_as_prefix then
								l_prefix := l_name
							else
								l_prefix := Void
							end
							Result.append (to_key_value_pairs (la_reference, l_prefix))
						end
					end
				else

				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	key_value_pair (a_key: STRING; a_value: ANY): TUPLE [STRING, STRING]
			--
		local
			l_url_utf8: UTF8_URL_ENCODER
		do
			to_camel_case (a_key)
			create l_url_utf8
--			Result := l_url_utf8.encoded_string (a_key) + "=" + l_url_utf8.encoded_string (a_value.out) + "&"
			Result := [l_url_utf8.encoded_string (a_key), l_url_utf8.encoded_string (a_value.out)]
		end

	to_camel_case (s: STRING)
			--
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > s.count
			loop
				if s [i] = '_' then
					s.remove (i)
					s [i] := s [i].upper
				end
				i :=i + 1
			end
		end

end
