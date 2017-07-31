function TableView.InternalDataSource (UI)
	local self = {}
	local InternalDataSource = Class (self, Glass.IListViewDataSource)

	function self:ctor (tableView)
		self.TableView = tableView
		
		self.DataSource = nil
		
		self.RowHeight = 20
		
		self.ItemCount = 0
		self.Items     = {}
	end

	function self:dtor ()
		self:SetDataSource (nil)
	end

	-- IListViewDataSource
	function self:GetItemCount ()
		return self.ItemCount
	end

	function self:CreateItem (type)
		return UI.TableView.ListViewItem ()
	end

	function self:BindItem (i, listViewItem)
		listViewItem:Bind (self:GetItem (i))
		return listViewItem
	end
	
	function self:UnbindItem (i, listViewItem)
		listViewItem:Unbind ()
	end
	
	function self:GetRangeHeight (startIndex, count, width)
		return self.RowHeight * count
	end
	
	function self:GetItemHeight (i, width)
		return self.RowHeight
	end

	-- TableViewInternalDataSource
	function self:GetTableView ()
		return self.TableView
	end
	
	function self:GetRowHeight ()
		return self.RowHeight
	end
	
	function self:SetRowHeight (rowHeight)
		if self.RowHeight == rowHeight then return end
		
		self.RowHeight = rowHeight
	end
	
	-- Items
	function self:AddItem (tableViewItem)
		self.ItemCount = self.ItemCount + 1
		self.Items [self.ItemCount] = tableViewItem
		
		self.ItemsInserted:Dispatch (self.ItemCount, 1)
	end

	function self:ClearItems ()
		if self.ItemCount == 0 then return end
		
		local itemCount = self.ItemCount
		self.ItemCount = 0
		self.Items     = {}
		
		self.ItemsRemoved:Dispatch (1, itemCount)
	end

	function self:GetItemLazy (i)
		return self.Items [i]
	end

	function self:InsertItem (index, tableViewItem)
		for i = self.ItemCount, index, -1 do
			self.Items [i + 1] = self.Items [i]
		end
		
		self.ItemCount = self.ItemCount + 1
		self.Items [index] = tableViewItem
		
		self.ItemsInserted:Dispatch (index, 1)
	end

	function self:RemoveItem (index)
		self.ItemCount = self.ItemCount - 1
		
		for i = index, self.ItemCount do
			self.Items [i] = self.Items [i + 1]
		end
		self.Items [self.ItemCount + 1] = nil
		
		self.ItemsRemoved:Dispatch (index, 1)
	end
	
	-- Data Source
	function self:GetDataSource ()
		return self.DataSource
	end

	function self:SetDataSource (dataSource)
		if self.DataSource == dataSource then return end
		
		if self.DataSource then
		end
		
		self.DataSource = dataSource
		
		if self.DataSource then
		end
	end
	
	return InternalDataSource
end
