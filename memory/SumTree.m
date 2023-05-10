classdef SumTree < handle

    properties
        stock;                          %stock
        stock_glb;                      %global inventory
        NodeDataProcess_enable;         %Whether to enable data processing    

        tree_WriteIdx;                  %next write index in the tree
        tree_Capacity;                  %Capacity of the tree (maximum amount of data)
        tree_NodeData;                  %The data of each node of the tree (colarray)
        tree_NodeDataProcessHandle;     %Methods for processing node data of a tree

        node_DataMemory;                %Used to store the external data (colarray) corresponding to the node
        node_NodeData;                  %Node data constructed in input order (colarray)
        node_rawNodeData;               %raw node data (colarray) constructed in input order                   
    end

    %Build and get variables
    methods
        function [obj, capacity] = SumTree(capacity)
            %Only supports full binary trees
            capacity = obj.check_capacity(capacity);
            obj.setup(capacity);
        end
        
        function setup(obj,capacity)
            obj.stock = 0;
            obj.stock_glb = 0;
            obj.NodeDataProcess_enable = false;
            obj.tree_WriteIdx = 1;
            obj.tree_Capacity = capacity;
            obj.tree_NodeData = zeros(2 * capacity - 1, 1);
            obj.node_DataMemory = zeros(capacity, 1);
            obj.node_NodeData = zeros(capacity, 1);
            obj.node_rawNodeData = zeros(capacity, 1);
            obj.tree_NodeDataProcessHandle = function_handle.empty;
        end

        %
        function value = check_capacity(~, capacity)
            capacity = round(capacity);
            if(bitand(capacity, capacity - 1) == 0)
                value = capacity;
                return
            end
            if(capacity <= 0)
                warning('Illegal capacity, adjusted to the default value of 512');
                value = 512;
                return
            end
            warning(['The tree capacity needs to be an integer power of 2, ' ...
                'automatically adjusted to the nearest number']);
            c_bin = dec2bin(capacity);
            power = length(c_bin) * ones(3, 1);
            power(1) = power(1) - 1;
            power(3) = power(3) + 1;
            c_near = 2.^(power);
            tem = abs(c_near - capacity);
            value = c_near(tem == min(tem));
            disp(['tweak to', num2str(value)]);
        end

        %get the root
        function  value = get_rootNodeData(obj)
            value = obj.tree_NodeData(1);
        end

        %Backup all data and go back, clearing all data in tree
        function stc = clear(obj)
            stc.stock = obj.stock;
            stc.stock = obj.stock_glb;
            stc.tree_Capacity = obj.tree_Capacity;
            stc.tree_NodeData = obj.tree_NodeData;
            stc.node_DataMemory = obj.node_DataMemory;
            stc.node_NodeData = obj.node_NodeData;
            stc.node_rawNodeData = obj.node_rawNodeData;
            obj.setup(obj.tree_Capacity);
        end
    end
    
    %Related to tree generation and update
    methods
        %Pass the update to the parent node
        function propagate_sgnode(obj, idx, change)
            parent_idx = floor(idx / 2);
            obj.tree_NodeData(parent_idx) = obj.tree_NodeData(parent_idx) + change;
            if(parent_idx ~= 1)
                obj.propagate_sgnode(parent_idx, change);
            end
        end

        %Single node update
        function update_sgnode(obj, idx, nd)
            change = nd - obj.tree_NodeData(idx);
            obj.tree_NodeData(idx) = nd;
            obj.propagate_sgnode(idx, change);
        end

        %add single node
        function add_sgnode(obj, rnd, dm, update)
            if nargin == 3
                update = false;
            end
            obj.node_DataMemory(obj.tree_WriteIdx) = dm;
            obj.node_rawNodeData(obj.tree_WriteIdx) = rnd;
            obj.do_DataProcess();
            if(update)
                idx = obj.tree_WriteIdx + obj.tree_Capacity - 1;
                obj.update_sgnode(idx, rnd);
            end
            obj.tree_WriteIdx = obj.tree_WriteIdx + 1;
            if obj.tree_WriteIdx > obj.tree_Capacity
                obj.tree_WriteIdx = 1;
            end
            obj.stock = obj.stock + 1;
            obj.stock_glb = obj.stock_glb + 1;
            if(obj.stock > obj.tree_Capacity)
                obj.stock = obj.tree_Capacity;
            end
        end

        %Add multiple nodes
        function add_mtpnode(obj, rnd, dm, update)
            if nargin == 3
                update = true;
            end
            assert(length(rnd) == length(dm), "error in dim");
            num = length(rnd);
            idxArray = obj.tree_WriteIdx : obj.tree_WriteIdx + num - 1;
            idxArray(idxArray > obj.tree_Capacity) = idxArray(idxArray > obj.tree_Capacity) - obj.tree_Capacity;
            obj.node_DataMemory(idxArray) = dm;
            obj.node_rawNodeData(idxArray) = rnd;
            obj.do_DataProcess();
            obj.tree_NodeData(obj.tree_Capacity : 2*obj.tree_Capacity - 1) = obj.node_NodeData;
            if(update)
                obj.update_tree();
            end
            obj.tree_WriteIdx = obj.tree_WriteIdx + num;
            if obj.tree_WriteIdx > obj.tree_Capacity
                obj.tree_WriteIdx = obj.tree_WriteIdx - obj.tree_Capacity;
            end
            obj.stock = obj.stock + num;
            obj.stock_glb = obj.stock_glb + num;
            if(obj.stock > obj.tree_Capacity)
                obj.stock = obj.tree_Capacity;
            end
        end

        %update tree
        function update_tree(obj)
            updata_num = length(dec2bin(obj.tree_Capacity)) - 1;
            tree_idxArray = obj.tree_Capacity : 2*obj.tree_Capacity - 1;
            tree_idxArray_parent = obj.array_half(tree_idxArray);
            for i = 1:updata_num
                obj.tree_NodeData(tree_idxArray_parent) = obj.near2_add(obj.tree_NodeData(tree_idxArray));
                tree_idxArray = tree_idxArray_parent;
                tree_idxArray_parent = obj.array_half(tree_idxArray_parent);
            end
        end

        %Add two points
        function value = near2_add(~, data)
            if(bitand(length(data), length(data) - 1))
                error("error in Capacity");
            end
            len = length(data);
            value = data(1:2:end) + data(2:2:end);
            assert(length(value) == 0.5*len);
        end

        %Index length is halved
        function value = array_half(~, data)
            value = data(1)*0.5 : (data(1) + length(data))*0.5 - 1;
        end
    end

    %Data Sample Addressing
    methods
        %Get the corresponding node number from the node
        function value = retrieve_sgnode(obj, idx, s)
            idx_left = 2 * idx;
            idx_right = idx_left + 1;
            if(idx_left >= length(obj.tree_NodeData))
                value = idx;
                return
            end
            if(s <= obj.tree_NodeData(idx_left))
                value = obj.retrieve_sgnode(idx_left, s);
            else
                value = obj.retrieve_sgnode(idx_right, s - obj.tree_NodeData(idx_left));
            end
        end

        %Sampling in a tree
        function stc = sample(obj, num, s_send)
            if(num >= obj.stock)
                warning('The number of samples exceeds the stock, reset to stock');
                num = obj.stock;
            end
            if nargin == 2
               s_send = rand(num, 1) * obj.get_rootNodeData(); 
            end
            stc.NodeData = zeros(num, 1);
            stc.rawNodeData = zeros(num, 1);
            stc.DataMemory = zeros(num, 1);
            for i = 1:num
                idx = obj.retrieve_sgnode(1, s_send(i));
                stc.NodeData(i) = obj.tree_NodeData(idx);
                stc.rawNodeData(i) = obj.node_rawNodeData(idx + 1 - obj.tree_Capacity);
                stc.DataMemory(i) = obj.node_DataMemory(idx + 1 - obj.tree_Capacity);
            end
        end
    end

    %关于节点数据处理的方法
    methods
        %获取数据处理相关结构体
        function stc = get_DataProcessStc(~, ~)
            if(nargin == 1)
                disp([ '********************************************************', newline, ...
                 'Set the logarithmic node data set processing method by the value of the returned structure: ', newline, ...
                 'enable: whether to use data processing (true/false)', newline, ...
                 'method: use the built-in processing method ("sigmoid","default"/"sumprob")', newline, ...
                 'method_api: Whether to use the built-in processing method (true/false)', newline, ...
                 ['ud_handle: define the processing function by yourself, assign value to the variable ' ...
                 '(have the ability to process matrix points)'], newline, ...
                 '*****************************************************', newline, ...
                 ' -The reminder can be skipped by entering any parameters when calling this function- ']);
            end
            stc.enable = true;
            stc.method = string.empty;
            stc.method_api = true;
            stc.ud_handle = function_handle.empty;
        end

        %Test user-defined data processing functions
        function result = test_handle(~, handle)
            result = true;
            try 
                handle(randperm(3595, 17));
            catch
                warning("The user-defined handle needs to have the ability to process matrix points " + ...
                    "--> use the default processing function");
                result = false;
            end
        end

        %Set data processing method
        function set_DataProcessHandle(obj, process_stc)
            if(process_stc.enable == false)
                return;
            end
            if(process_stc.method_api || isempty(process_stc.ud_handle))
                switch process_stc.method
                    case "softmax"
                        handle = @obj.softmax;
                    otherwise
                        handle = @obj.sum_prob;
                end
            else
                if(obj.test_handle(process_stc.ud_handle))
                    handle = process_stc.ud_handle;
                else
                    handle = @obj.sum_prob;
                end
            end
            obj.tree_NodeDataProcessHandle = handle;
        end

        %data processing
        function do_DataProcess(obj)
            if(obj.NodeDataProcess_enable == false)
                obj.node_NodeData = obj.node_rawNodeData;
                return
            end
            if(isempty(obj.tree_NodeDataProcessHandle))
                warning("No data handle is set, use the default");
                obj.set_DataProcessHandle(obj.get_DataProcessStc(1));
            end
            obj.node_NodeData = obj.tree_NodeDataProcessHandle(obj.node_rawNodeData);
        end

        %Modify data processing handle
        function alter_DataProcessHandle(obj, process_struct)
            obj.set_DataProcessHandle(process_struct);
            obj.do_DataProcess();
            obj.update_tree();%update all nodes
        end

        %Probability Summation Processing Method
        function value = sum_prob(~, data)
            value = data ./ sum(data);
        end

        %softmax Processing Method
        function value = softmax(~, data)
            data = exp(data);
            value = data ./ sum(data);
        end
    end
end