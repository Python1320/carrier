CompactList = {}

function CompactList.at(n, data, i)
	if n == 0 then
		return nil
	elseif n == 1 then
		return i == 1 and data or nil
	else
		return data[i]
	end
end

function CompactList.count(n, data)
	return n
end

function CompactList.enumerator(n, data)
	if n == 0 then
		return function() return nil end
	elseif n == 1 then
		local i = 0
		return function()
			i = i + 1
			return i == 1 and data or nil
		end
	else
		local i = 0
		return function()
			i = i + 1
			return list[i]
		end
	end
end

function CompactList.clear(n, data)
	return 0, nil
end

function CompactList.append(n, data, x)
	if n == 0 then
		return 1, x
	elseif n == 1 then
		return 2, { data, x }
	else
		data[n + 1] = x
		return n, data
	end
end

function CompactList.pack(...)
	local n = select("#", ...)
	if n == 0 then
		return 0, nil
	elseif n == 1 then
		local first = ...
		return n, first
	else
		return n, { ... }
	end
end

function CompactList.unpack(n, data)
	if n == 0 then
		return
	elseif n == 1 then
		return data
	else
		return unpack(data, 1, n)
	end
end

return CompactList