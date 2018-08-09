classdef uiHMM < handle
    
    properties
        gui
        workspace
    end
    
    methods
        function obj=uiHMM()
            % loaded data
            obj.workspace.data = {};
            obj.workspace.metadata = {};
            % generated data
            obj.workspace.generated_data = {};
            obj.workspace.generated_metadata = {};
            % viterbi sequence
            obj.workspace.viterbi_results = {};
            obj.workspace.viterbi_metadata = {};
            % training results
            obj.workspace.training_results = {};
            obj.workspace.training_metadata = {};
            % decoded results
            obj.workspace.decode_results = {};
            obj.workspace.decode_metadata = {};
            % model
            obj.workspace.model = {};
            % current workspace filename
            obj.workspace.ws_filename = '';
            
            % ui creation
            obj.gui.fig = figure(...
                'units', 'pixels',...
                'position', [100 100 600 400],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'name', 'uiH[S]MM',...
                'numbertitle', 'off',...
                'resize', 'off');

            % Menues
            obj.create_file_menu();
            obj.create_model_menu();
            obj.create_inference_menu();
            obj.create_view_menu();
            
            obj.create_main_screen();
                        
            % show Workspace status
            obj.show_workspace();
            
            obj.load_opt();
        end
        
        function load_opt(obj)
            program_option;
            obj.workspace.opt = opt;
        end
        
        % create menues
        function create_file_menu(obj)
            % File menu
            obj.gui.file_menu = uimenu(obj.gui.fig,...
                'Label', 'Data');
            
            % Import Data submenu
            obj.gui.import_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Import data');
            % Open Ascii Action
            obj.gui.open_ascii_menu = uimenu(obj.gui.import_menu,...
                'Label', 'From ASCII/float file');
            % Open Mat File Action
            obj.gui.open_matlab_menu = uimenu(obj.gui.import_menu,...
                'Label', 'From Matlab file');
            % Open Global Workspace Variable Action
            obj.gui.open_matlab_ws_menu = uimenu(obj.gui.import_menu,...
                'Label', 'From Matlab Workspace');
            % Open EEGLAB File Action
            obj.gui.open_eeglab_menu = uimenu(obj.gui.import_menu,...
                'Label', 'From EEGLAB file');
            % Open SPM File Action
            obj.gui.open_SPM_menu = uimenu(obj.gui.import_menu,...
                'Label', 'From SPM file');

            % Export Data submenu
            obj.gui.export_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Export data',...
                'Enable', 'off');
            % Save Ascii Action
            obj.gui.save_ascii_menu = uimenu(obj.gui.export_menu,...
                'Label', 'To ASCII/float file');
            % Save Mat File Action
            obj.gui.save_matlab_menu = uimenu(obj.gui.export_menu,...
                'Label', 'To Matlab file');
            % Save EEGLAB File Action
            obj.gui.save_eeglab_menu = uimenu(obj.gui.export_menu,...
                'Label', 'To EEGLAB file');
            % Save SPM File Action
            obj.gui.save_SPM_menu = uimenu(obj.gui.export_menu,...
                'Label', 'To SPM file');

            % Load dataset
            obj.gui.load_workspace_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Load Existing Analysis',...
                'Separator', 'on');
            % Save dataset
            obj.gui.save_workspace_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Save Current Analysis',...
                'Enable', 'off');
            % Save as dataset
            obj.gui.save_as_workspace_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Save Current Analysis As',...
                'Enable', 'off');
            % clear dataset
            obj.gui.clear_workspace_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Clear Analysis',...
                'Enable', 'off');
            % quit app
            obj.gui.quit_menu = uimenu(obj.gui.file_menu,...
                'Label', 'Quit',...
                'Separator', 'on');

            % set callback
            % import
            obj.gui.open_ascii_menu.Callback = @obj.open_ascii_action;
            obj.gui.open_matlab_menu.Callback = @obj.open_matlab_action;
            obj.gui.open_matlab_ws_menu.Callback = @obj.open_matlab_ws_action;
            % other menues
            obj.gui.load_workspace_menu.Callback = @obj.load_workspace_action;
            obj.gui.save_workspace_menu.Callback = {@obj.save_workspace_action, 0};
            obj.gui.save_as_workspace_menu.Callback = {@obj.save_workspace_action, 1};
            obj.gui.clear_workspace_menu.Callback = @obj.clear_workspace_action;
        end
           
        function create_model_menu(obj)
            % Model menu
            obj.gui.model_menu = uimenu(obj.gui.fig,...
                'Label', 'Model');
            % Create Model Action
            obj.gui.create_model_menu = uimenu(obj.gui.model_menu,...
                'Label', 'Create Model');
            % Prior Distribution Action
            obj.gui.prior_dist_menu = uimenu(obj.gui.model_menu,...
                'Label', 'Prior Distributions',...
                'Enable', 'off');
            % Posteriori Distribution Action
            obj.gui.posterior_dist_menu = uimenu(obj.gui.model_menu,...
                'Label', 'Posterior Distributions',...
                'Enable', 'off');
            
            % set callbacks
            obj.gui.create_model_menu.Callback = @obj.create_model_action;
            obj.gui.prior_dist_menu.Callback = @obj.prior_dist_action;
            obj.gui.posterior_dist_menu.Callback = @obj.posteriori_dist_action;
        end

        function create_inference_menu(obj)
            % Inference menu
            obj.gui.inference_menu = uimenu(obj.gui.fig,...
                'Label', 'Inference');
            % Training Model Action
            obj.gui.train_model_menu = uimenu(obj.gui.inference_menu,...
                'Label', 'Train Model',...
                'Enable', 'off');
            % Data Decode Action
            obj.gui.data_decode_menu = uimenu(obj.gui.inference_menu,...
                'Label', 'State Probabilities',...
                'Enable', 'off');
            % Generate from Model Action
            obj.gui.generate_data_menu = uimenu(obj.gui.inference_menu,...
                'Label', 'Generate Data',...
                'Enable', 'off');
            % Sequence estimation by Viterbi
            obj.gui.sequence_estimation_menu = uimenu(obj.gui.inference_menu,...
                'Label', 'Viterbi Decoding',...
                'Enable', 'off');
            
            % set callbacks
            obj.gui.train_model_menu.Callback = @obj.train_model_action;
            obj.gui.data_decode_menu.Callback = @obj.data_decode_action;
            obj.gui.generate_data_menu.Callback = @obj.generate_data_action;
            obj.gui.sequence_estimation_menu.Callback = @obj.sequence_estimation_action;
        end

        function create_view_menu(obj)
            % View menu
            obj.gui.view_menu = uimenu(obj.gui.fig,...
                'Label', 'View');
            % Secuence Action
            obj.gui.plot_sequence_menu = uimenu(obj.gui.view_menu,...
                'Label', 'Sequence',...
                'Enable', 'off');
            % Ocupancia(poner en ingles) Action
            obj.gui.plot_occupancy_menu = uimenu(obj.gui.view_menu,...
                'Label', 'Occupancy',...
                'Enable', 'off');
            % duration histogram Action
            obj.gui.plot_histogram_menu = uimenu(obj.gui.view_menu,...
                'Label', 'Duration Histogram',...
                'Enable', 'off');
            
            % set callbacks
            obj.gui.plot_sequence_menu.Callback = @obj.plot_sequence_action;
            obj.gui.plot_occupancy_menu.Callback = @obj.plot_occupancy_action;
            obj.gui.plot_histogram_menu.Callback = @obj.plot_histogram_action;
        end

        % create main screen
        function create_main_screen(obj)
            % tab container
            obj.gui.tabs_container = uitabgroup(obj.gui.fig);

            % tab for status
            obj.gui.tab_status = uitab(obj.gui.tabs_container, 'Title', 'Status');

            % create status bar
            obj.gui.status_bar = uicontrol(obj.gui.fig,...
                'units', 'pixels',...
                'Position', [10 5 558 25],...
                'FontSize', 12,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Ready');

            y = 10;
            % temp
            y = y + 145;
            obj.gui.model_panel = uipanel(obj.gui.tab_status,...
                'TitlePosition', 'centertop',...
                'units', 'pixels',...
                'Position', [10 y 578 130],...
                'FontSize', 10,...
                'Title', 'Model');
            obj.gui.prior_label = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [10 85 135 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Prior Distributions');
            obj.gui.prior_value = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [145 85 90 15],...
                'FontSize', 9,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '???');
            obj.gui.posterior_label = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [10 60 135 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Posterior Distributions');
            obj.gui.posterior_value = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [145 60 90 15],...
                'FontSize', 9,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '???');
            obj.gui.parsampl_label = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [10 35 135 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Parsampl Distributions');
            obj.gui.parsampl_value = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [145 35 90 15],...
                'FontSize', 9,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '???');
            obj.gui.nstates_label = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [10 10 60 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '# States');
            obj.gui.nstates_value = uicontrol(obj.gui.model_panel,...
                'units', 'pixels',...
                'Position', [70 10 90 15],...
                'FontSize', 9,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '???');
            
            y = y + obj.gui.model_panel.Position(4);
            obj.gui.data_panel = uipanel(obj.gui.tab_status,...
                'TitlePosition', 'centertop',...
                'units', 'pixels',...
                'Position', [10 y 578 80],...
                'FontSize', 10,...
                'Title', 'Data');
            % filename label and edit
            obj.gui.data_filename_label = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [10 35 60 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Data File:');
            obj.gui.data_filename_value = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [70 35 458 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '');
            % dimension label and edit
            obj.gui.data_dimension_label = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [10 10 90 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '# of Channels:');
            obj.gui.data_dimension_value = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [100 10 40 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '');
            % length label and edit
            obj.gui.data_length_label = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [180 10 75 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', 'Data Length:');
            obj.gui.data_length_value = uicontrol(obj.gui.data_panel,...
                'units', 'pixels',...
                'Position', [265 10 40 15],...
                'FontSize', 9,...
                'HorizontalAlignment', 'left',...
                'Style', 'text',...
                'String', '');
        end

        % callbacks
        function open_ascii_action(obj, ~, ~)
            % ask for file
            [selected_file, path] = uigetfile({'*.*',  'All Files (*.*)'});
            % if a file is selected
            if selected_file ~= 0
                % open and store it
                filename = [path selected_file];
                % read data
                data = load(filename);
                % store in the object
                obj.workspace = setfield(obj.workspace, '_data', data);
                % ask for a name
                name = inputdlg({'Name the data:'}, 'Name?', [1 50], {'my data'});
                % if cancel or give empty string assing default one
                if isempty(name)
                    name = {'my data'};
                end
                % store metadata
                metadata = {}
                metadata.filename = [path selected_file];
                metadata.name = name{1};
                metadata.dimension = size(data, 2);
                metadata.length = size(obj.workspace.data, 1);
                obj.workspace = setfield(obj.workspace, 'metadata', metadata);
                % refresh info 
                obj.show_workspace();
                obj.set_status_bar(['Loaded "' selected_file '"']);
            end
            obj.menu_enable_state();
        end

        function open_matlab_action(obj, ~, ~)
            % ask for file
            [selected_file, path] = uigetfile({'*.mat',  'Matlab File (*.mat)'});
            % if a file is selected
            if selected_file ~= 0
                % open the data
                filename = [path selected_file];
                new_data = load(filename);
                % get the keys
                fields_data = fields(new_data);
                % display a selection list
                [indx,tf] = listdlg('PromptString', 'Select Data:',...
                    'SelectionMode', 'single',...
                    'ListString', fields_data);
                if ~tf
                    % cancel the loading by close or press cancel
                    return;
                end
                % get the first field
                value = getfield(new_data, fields_data{indx});
                % store the data
                obj.workspace.data = value;
                % ask for a name
                name = inputdlg({'Name the data:'}, 'Name?', [1 50], {'my data'});
                % if cancel or give empty string assing default one
                if isempty(name)
                    name = {'my data'};
                end
                % store metadata
                metadata = {};
                metadata.filename = strcat(path, selected_file);
                metadata.name = name{1};
                metadata.dimension = size(obj.workspace.data, 2);
                metadata.length = size(obj.workspace.data, 1);
                obj.workspace.metadata = metadata;
                % refresh info 
                obj.show_workspace();
                obj.set_status_bar(['Loaded "' fields_data{indx} '" from file "' selected_file '" Loaded']);
            end
            obj.menu_enable_state();
        end

        function open_matlab_ws_action(obj, ~, ~)
            % retrieve var from global workspace
            vars = evalin('base', 'who()');
            % ask the user to select one
            [indx,tf] = listdlg('PromptString', 'Select Data:',...
                'SelectionMode', 'single',...
                'ListString', vars);
            if ~tf
                % cancel the loading by close or press cancel
                return;
            end
            % get the value
            value = evalin('base', vars{indx});
            % assign data
            obj.workspace.data = value;
            obj.workspace.metadata.filename = '(from matlab workspace)';
            obj.workspace.metadata.name = vars{indx};
            obj.workspace.metadata.dimension = size(obj.workspace.data, 2);
            obj.workspace.metadata.length = size(obj.workspace.data, 1);
            % refresh info 
            obj.show_workspace();
            obj.set_status_bar(['Loaded "' vars{indx} '" from Workspace']);
            obj.menu_enable_state();
        end

        function save_workspace_action(obj, ~, ~, save_as)
            data = obj.get_select_vars('Save');
            if (~isempty(data))
                % if at least one of the workspace fields is selected
                something_to_save = any(cell2mat(arrayfun(@(t){getfield(data, t{1});}, fields(data))));
                if ~something_to_save
                    disp('nothing to save');
                    return;
                end
                
                % ask for file if save_as
                if save_as || isempty(obj.workspace.ws_filename)
                    [selected_file, path] = uiputfile({'*.mat',  'Matlab File (*.mat)'});
                    % if a file is selected
                    if selected_file == 0
                        return;
                    end
                    
                    obj.workspace.ws_filename = [path selected_file];
                end

                % opt values
                if isfield(data, 'opt') && data.opt
                    ws.opt = obj.workspace.opt;
                end
                % viterbi sequence
                if isfield(data, 'viterbi') && data.viterbi
                    ws.viterbi_results = obj.workspace.viterbi_results;
                    ws.viterbi_metadata = obj.workspace.viterbi_metadata;
                end
                % generated data
                if isfield(data, 'generated') && data.generated
                    ws.generated_data = obj.workspace.generated_data;
                    ws.generated_metadata = obj.workspace.generated_metadata;
                end
                % decoded data
                if isfield(data, 'decode') && data.decode
                    ws.decode_results = obj.workspace.decode_results;
                    ws.decode_metadata = obj.workspace.decode_metadata;
                end
                % results
                if isfield(data, 'results') && data.results
                    ws.training_results = obj.workspace.training_results;
                    ws.training_metadata = obj.workspace.training_metadata;
                end
                % model
                if isfield(data, 'model') && data.model
                    ws.model = obj.workspace.model;
                end
                % training data
                if isfield(data, 'data') && data.data
                    ws.data = obj.workspace.data;
                    ws.metadata = obj.workspace.metadata;
                end

                save(obj.workspace.ws_filename, 'ws');
                pieces = strsplit(obj.workspace.ws_filename, '\');
                obj.set_status_bar(['Analysis "' pieces{size(pieces,1)} '" Saved']);
            end
            obj.menu_enable_state();
        end

        function load_workspace_action(obj, ~, ~)
            % ask for file
            [selected_file, path] = uigetfile({'*.mat',  'Matlab File (*.mat)'});
            % if a file is selected
            if selected_file ~= 0
                % open the data
                filename = [path selected_file];
                data = load(filename);
                % put variables in workspace
                vars = fields(data.ws);
                for i=1:size(vars,1)
                    var_value = getfield(data.ws, vars{i});
                    obj.workspace = setfield(obj.workspace, vars{i}, var_value);
                end
                % store the filename and refresh home view
                obj.workspace.ws_filename = filename;
                obj.show_workspace();
                obj.set_status_bar(['Analysis "' selected_file '" Loaded']);
            end
            obj.menu_enable_state();
        end

        function clear_workspace_action(obj, ~, ~)
            data = obj.get_select_vars('Clear');
            if (~isempty(data))
                % opt values
                if isfield(data, 'opt') && data.opt
                    obj.workspace.opt = {};
                end
                % viterbi sequence
                if isfield(data, 'viterbi') && data.viterbi
                    obj.workspace.viterbi_results = {};
                    obj.workspace.viterbi_metadata = {};
                end
                % generated data
                if isfield(data, 'generated') && data.generated
                    obj.workspace.generated_data = {};
                    obj.workspace.generated_metadata = {};
                end
                % decoded data
                if isfield(data, 'decode') && data.decode
                    obj.workspace.decode_results = {};
                    obj.workspace.decode_metadata = {};
                end
                % results
                if isfield(data, 'results') && data.results
                    obj.workspace.training_results = {};
                    obj.workspace.training_metadata = {};
                end
                % model
                if isfield(data, 'model') && data.model
                    obj.workspace.model = {};
                end
                % training data
                if isfield(data, 'data') && data.data
                    obj.workspace.data = {};
                    obj.workspace.metadata = {};
                end
                % drop the filename
                obj.workspace.ws_filename = '';
                
                obj.show_workspace();
                obj.set_status_bar('Analysis Dropped');
            end
            obj.menu_enable_state();
        end
        
        function create_model_action(obj, ~, ~)
            data = obj.get_model();
            if (~isempty(data))
                obj.workspace.model = data.model;
                obj.show_workspace();
                obj.set_status_bar('Model Created');
            end
            obj.menu_enable_state();
        end
           
        function prior_dist_action(obj, ~, ~)
            data = obj.get_distribution(1);
            if (~isempty(data))
                model_name = class(obj.workspace.model);
                % put the new parameters in the model
                obj.workspace.model.emis_model.prior = data.emis;
                if strcmp(model_name, 'hsmm')
                    obj.workspace.model.dur_model.prior = data.dur;
                end
                obj.workspace.model.trans_model.prior = data.trans;
                obj.workspace.model.in_model.prior = data.init;
                obj.set_status_bar('Prior Modified');
            end
            obj.menu_enable_state();
        end
           
        function posteriori_dist_action(obj, ~, ~)
            obj.get_distribution(0);
        end

        function train_model_action(obj, ~, ~)
            if ~obj.check_opt()
                return;
            end

            data = obj.get_estimation();
            if (~isempty(data))
                if isempty(obj.workspace.model)
                    disp('No hay modelo'); 
                    return
                end
                if isempty(obj.workspace.data)
                    disp('No hay datos para entrenar'); 
                    return
                end
                
                obj.set_status_bar('Training Model...');
                % set learning algorithm
                if strcmp(data.learning_algorithm, 'Variational Bayes')
                    obj.workspace.opt = setfield(obj.workspace.opt, 'train', 'VB');
                elseif strcmp(data.learning_algorithm, 'Expectation Maximization')
                    obj.workspace.opt = setfield(obj.workspace.opt, 'train', 'EM');
                end
                % set init option
                if strcmp(data.initialization, 'K-means')
                    obj.workspace.opt = setfield(obj.workspace.opt, 'initoption', 'kmeans');
                elseif strcmp(data.initialization, 'Random')
                    obj.workspace.opt = setfield(obj.workspace.opt, 'initoption', 'random');
                end
                % set numeric parameters
                obj.workspace.opt = setfield(obj.workspace.opt, 'matixer', data.maxiter);
                obj.workspace.opt = setfield(obj.workspace.opt, 'nrep', data.n_repetitions);
                obj.workspace.opt = setfield(obj.workspace.opt, 'tol', data.tolerance);
                obj.workspace.opt = setfield(obj.workspace.opt, 'maxcyc', data.max_cycles);
                obj.workspace.opt = setfield(obj.workspace.opt, 'dmax', data.dmax);
                obj.workspace.opt = setfield(obj.workspace.opt, 'minstates', data.n_states{1});
                obj.workspace.opt = setfield(obj.workspace.opt, 'maxstates', data.n_states{2});
                % set init option
                if data.verbose
                    obj.workspace.opt = setfield(obj.workspace.opt, 'verbose', 'yes');
                else
                    obj.workspace.opt = setfield(obj.workspace.opt, 'verbose', 'no');
                end
                results = obj.workspace.model.train(obj.workspace.data, 'opt', obj.workspace.opt);
                obj.workspace.training_results = results;
                obj.show_workspace();
                obj.set_status_bar('Model Trained');
            end
            obj.menu_enable_state();
        end

        function data_decode_action(obj, ~, ~)
            if ~obj.check_opt()
                return;
            end
            
            choice = questdlg('Do you want to start decoding?',...
                'Decode',...
                'Yes', 'No', 'Yes');
            if strcmp(choice, 'Yes')
                obj.set_status_bar('Decoding Data...');
                decode_results = obj.workspace.model.decode(obj.workspace.data);
                obj.workspace.decode_results = decode_results;
                obj.set_status_bar('Data Decoded');
            end
            obj.menu_enable_state();
        end
        
        function generate_data_action(obj, ~, ~)
            if ~obj.check_opt()
                return;
            end

            data = obj.get_generation();
            if (~isempty(data))
                obj.set_status_bar('Generating data...');
                model_name = class(obj.workspace.model);
                % set data
                obj.workspace.model.trans_model.parsampl = data.parameters.trans;
                obj.workspace.model.in_model.parsampl = data.parameters.in;
                obj.workspace.model.emis_model.parsampl = data.parameters.emis;
                if strcmp(model_name, 'hsmm')
                    obj.workspace.model.dur_model.parsampl = data.parameters.dur;
                end
                % generate data
                new_data = obj.workspace.model.gen(data.n);
                obj.workspace.generated_data = new_data;
                obj.show_workspace();
                obj.set_status_bar('Data generated');
            end
            obj.menu_enable_state();
        end
        
        function sequence_estimation_action(obj, ~, ~)
            if ~obj.check_opt()
                return;
            end

            choice = questdlg('Do you want to get most probable sequence?',...
                'Viterbi',...
                'Yes', 'No', 'Yes');
            if strcmp(choice, 'Yes')
                obj.set_status_bar('Calculating Most Probable Sequence...');
                viterbi_results = obj.workspace.model.viterbi(obj.workspace.data);
                obj.workspace.viterbi_results = viterbi_results;
                obj.set_status_bar('Most Probable Sequence Calculated');
            end
            obj.menu_enable_state();
        end

        function plot_sequence_action(obj, ~, ~)
            figure(...
                'units', 'pixels',...
                'Position', [100 100 600 400],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Sequence (using Viterbi)',...
                'numbertitle', 'off',...
                'resize', 'off');
            bar(obj.workspace.viterbi_results);
            xlabel('Time');
            ylabel('State');
            title('State Label');
        end
        
        function plot_occupancy_action(obj, ~, ~)
            figure(...
                'units', 'pixels',...
                'Position', [100 100 600 400],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Occupancy',...
                'numbertitle', 'off',...
                'resize', 'off');
            seq = obj.workspace.viterbi_results;
            [a b]=hist(seq,1:obj.workspace.model.nstates);
            bar(b,100.0*a/size(seq,2));
            xlabel('State Label');
            ylabel('% Ocupancy');
            title('State Ocupancy')
        end
        
        function plot_histogram_action(obj, ~, ~)
            figure(...
                'units', 'pixels',...
                'Position', [100 100 600 400],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Duration Histograms',...
                'numbertitle', 'off',...
                'resize', 'off');
            seq = obj.workspace.viterbi_results;
            [a b]=util.calculadur(seq);
            for j=1:obj.workspace.model.nstates
                subplot(obj.workspace.model.nstates,1,j);
                hist(a(b==j));
                ylabel('Counts');
                xlabel('State Duration');
                if j==1
                    title('State Duration Histograms');
                end
            end
        end
                
        % dialogs
        function data = get_model(obj)
            data = {};

            model_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 100 350 320],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Model Creation',...
                'numbertitle', 'off',...
                'resize', 'off');
            % Model HMM o HSMM
            model_selection = uibuttongroup(model_dialog,...
                'Title', 'Model Selection',...
                'units', 'pixels',...
                'Position', [10 260 330 50]);
            model_hsmm = uicontrol(model_selection,...
                'Style', 'radiobutton',...
                'Position', [20 10 110 20],...
                'String', 'HSMM');
            model_hmm = uicontrol(model_selection,...
                'Style', 'radiobutton',...
                'Position', [150 10 110 20],...
                'String', 'HMM');
            % emission dimension
            uicontrol(model_dialog,...
                'Style', 'text',...
                'Position', [70 230 150 20],...
                'String', 'Emission Channels',...
                'HorizontalAlignment', 'left');
            % set the data dimension in the dimension entry
            emis_dim = '';
            if ~isempty(obj.workspace.data)
                emis_dim = num2str(obj.workspace.metadata.dimension);
            end
            model_emission_dim_entry = uicontrol(model_dialog,...
                'Style', 'edit',...
                'Position', [240 230 30 20],...
                'String', emis_dim,...
                'HorizontalAlignment', 'left');
            % number of states
            uicontrol(model_dialog,...
                'Style', 'text',...
                'Position', [70 200 150 20],...
                'String', '# States (0: undefined)',...
                'HorizontalAlignment', 'left');
            model_states_entry = uicontrol(model_dialog,...
                'Style', 'edit',...
                'Position', [240 200 30 20],...
                'String', '0',...
                'HorizontalAlignment', 'left');
            % models
            model_component = uipanel(model_dialog,...
                'Title', 'Components',...
                'units', 'pixels',...
                'Position', [10 50 330 140]);
            uicontrol(model_component,...
                'Style', 'text',...
                'Position', [10 100 150 20],...
                'String', 'Emission Model',...
                'HorizontalAlignment', 'left');
            emis_opts = obj.classes_ls('emis_model');
            model_emission_combo = uicontrol(model_component,...
                'Style', 'popup',...
                'String', emis_opts,...
                'Position', [160 100 160 20]);
            uicontrol(model_component,...
                'Style', 'text',...
                'Position', [10 70 150 20],...
                'String', 'Transition Model',...
                'HorizontalAlignment', 'left');
            trans_opts = obj.classes_ls('trans_model');
            model_transition_combo = uicontrol(model_component,...
                'Style', 'popup',...
                'String', trans_opts,...
                'Position', [160 70 160 20]);
            uicontrol(model_component,...
                'Style', 'text',...
                'Position', [10 40 150 20],...
                'String', 'Initial Probability Model',...
                'HorizontalAlignment', 'left');
            in_opts = obj.classes_ls('in_model');
            model_initial_combo = uicontrol(model_component,...
                'Style', 'popup',...
                'String', in_opts,...
                'Position', [160 40 160 20]);
            model_duration_label = uicontrol(model_component,...
                'Style', 'text',...
                'Position', [10 10 150 20],...
                'String', 'Duration Model',...
                'HorizontalAlignment', 'left');
            dur_opts = obj.classes_ls('dur_model');
            model_duration_combo = uicontrol(model_component,...
                'Style', 'popup',...
                'String', dur_opts,...
                'Position', [160 10 160 20]);
            % help, create and cancel buttons
            help_button = uicontrol(model_dialog,...
                'Style', 'pushbutton',...
                'String', 'Help',...
                'Position', [10 10 50 20]);
            create_button = uicontrol(model_dialog,...
                'Style', 'pushbutton',...
                'String', 'Create',...
                'ForegroundColor', [0.0 0.8 0.0],...
                'Position', [230 10 50 20]);
            cancel_button = uicontrol(model_dialog,...
                'Style', 'pushbutton',...
                'String', 'Cancel',...
                'ForegroundColor', [0.8 0.0 0.0],...
                'Position', [290 10 50 20]);
            
            function select_HSMM(~, ~)
                model_duration_label.Enable = 'on';
                model_duration_combo.Enable = 'on';
            end
            
            function select_HMM(~, ~)
                model_duration_label.Enable = 'off';
                model_duration_combo.Enable = 'off';
            end
            
            function help_action(~, ~)
                disp('TODO help');
            end
            
            function create_action(~, ~)
                % get info
                selected_model = model_selection.SelectedObject.String;
                dimension = str2num(model_emission_dim_entry.String);
                n_states = str2num(model_states_entry.String);
                
                % validation values are numbers
                
                % define model
                if (strcmp(selected_model, 'HSMM'))
                    data.model = hsmm();
                else
                    data.model = hmm();
                end
                % parameters of model
                data.model.ndim = dimension;
                data.model.nstates = n_states;
                % assign models
                % emission
                selected_emis = emis_opts(model_emission_combo.Value);
                selected_emis = eval(['emis_model.' selected_emis{1} '(' num2str(dimension) ',' num2str(n_states) ')']);
                data.model.emis_model = selected_emis;
                % transition
                selected_trans = trans_opts(model_transition_combo.Value);
                selected_trans = eval(['trans_model.' selected_trans{1} '(' num2str(n_states) ')']);
                data.model.trans_model = selected_trans;
                % initial contition
                selected_in = in_opts(model_initial_combo.Value);
                selected_in = eval(['in_model.' selected_in{1} '(' num2str(n_states) ')']);
                data.model.in_model = selected_in;
                % duration contition
                if (strcmp(selected_model, 'HSMM'))
                    selected_dur = dur_opts(model_duration_combo.Value);
                    selected_dur = eval(['dur_model.' selected_dur{1} '(1,' num2str(n_states) ')']);
                    data.model.dur_model = selected_dur;
                end
                % close de dialog
                delete(model_dialog);
            end
            
            function cancel_action(~, ~)
                delete(model_dialog);
            end
            
            model_hmm.Callback = @select_HMM;
            model_hsmm.Callback = @select_HSMM;
            help_button.Callback = @help_action;
            create_button.Callback = @create_action;
            cancel_button.Callback = @cancel_action;

            uiwait(model_dialog);
        end

        function data = get_distribution(obj, is_prior)
            data = {};

            function new_values=non_inf()
                model_name = class(obj.workspace.model);
                % previous values
                previous.emis = obj.workspace.model.emis_model.prior;
                previous.trans = obj.workspace.model.trans_model.prior; 
                previous.in = obj.workspace.model.in_model.prior;
                if strcmp(model_name, 'hsmm')
                    previous.dur = obj.workspace.model.dur_model.prior;
                end
                % calculate
                obj.workspace.model.emis_model.priornoinf();
                obj.workspace.model.trans_model.priornoinf();
                obj.workspace.model.in_model.priornoinf();
                if strcmp(model_name, 'hsmm')
                    obj.workspace.model.dur_model.priornoinf();
                end
                % store
                new_values.emis = obj.workspace.model.emis_model.prior;
                new_values.trans = obj.workspace.model.trans_model.prior; 
                new_values.in = obj.workspace.model.in_model.prior;
                if strcmp(model_name, 'hsmm')
                    new_values.dur = obj.workspace.model.dur_model.prior;
                end
                % set old parameters
                obj.workspace.model.emis_model.prior = previous.emis;
                obj.workspace.model.trans_model.prior = previous.trans; 
                obj.workspace.model.in_model.prior = previous.in;
                if strcmp(model_name, 'hsmm')
                    obj.workspace.model.dur_model.prior = previous.dur;
                end
            end
            
            function refresh(src, ~, mod, data)
                params = data.ds_params;
                fs = fields(params);
                for i=1:size(fs,1)
                    tb = getfield(params, fs{i});
                    if strcmp(src.String{src.Value}, 'Non Informative')
                        ni = getfield(getfield(noinf, mod), fs{i});
                        tb.UserData = ni;
                        [labels{1:size(tb.Data,1),1:size(tb.Data,2)}] = deal('view');
                    else
                        [labels{1:size(tb.Data,1),1:size(tb.Data,2)}] = deal('edit');
                    end
                        tb.Data = labels;
                end
            end
            
            % non informative data
            if is_prior
                noinf = non_inf();
            end
            
            
            % global model name
            gm_name = class(obj.workspace.model);

            dist_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 50 500 400],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Prior Distributions',...
                'numbertitle', 'off',...
                'resize', 'off');
            if ~is_prior
                dist_dialog.Name = 'Posterior Distributions';
            end

            x = 0;
            y = 40;
            % THIS ONE DEPENDS ON MODEL (HMM or HSMM)
            % duration panel
            duration_panel = {};
            if(strcmp(gm_name, 'hsmm'))
                duration_panel = obj.get_emission_duration_panel(dist_dialog, 'Duration', obj.workspace.model.dur_model, is_prior);
                aux = duration_panel.ds_panel.Position;
                duration_panel.ds_panel.Position = [10 y aux(3) aux(4)];
                if is_prior
                    duration_panel.ds_combo.Callback = {@refresh, 'dur', duration_panel};
                end
                x = max(x, aux(3));
                y = y + 10 + aux(4);
            end
            % initial condition panel
            init_panel = obj.get_transition_initial_panel(dist_dialog, 'Initial Condition', obj.workspace.model.in_model, is_prior);
            aux = init_panel.ds_panel.Position;
            init_panel.ds_panel.Position = [10 y aux(3) aux(4)];
            if is_prior
                init_panel.ds_combo.Callback = {@refresh, 'in', init_panel};
            end
            x = max(x, aux(3));
            y = y + 10 + aux(4);
            % transition panel
            transition_panel = obj.get_transition_initial_panel(dist_dialog, 'Transition', obj.workspace.model.trans_model, is_prior);
            aux = transition_panel.ds_panel.Position;
            transition_panel.ds_panel.Position = [10 y aux(3) aux(4)];
            if is_prior
                transition_panel.ds_combo.Callback = {@refresh, 'trans', transition_panel};
            end
            x = max(x, aux(3));
            y = y + 10 + aux(4);
            % emission panel
            emission_panel = obj.get_emission_duration_panel(dist_dialog, 'Emission', obj.workspace.model.emis_model, is_prior);
            aux = emission_panel.ds_panel.Position;
            emission_panel.ds_panel.Position = [10 y aux(3) aux(4)];
            if is_prior
                emission_panel.ds_combo.Callback = {@refresh, 'emis', emission_panel};
            end
            x = max(x, aux(3))+20;
            y = y + 10 + aux(4);
            
            % recalculate the size of the dialog
            dist_dialog.Position = [100 50 x y];
            
            if(strcmp(gm_name, 'hsmm'))
                duration_panel.ds_panel.Position(3) = x-20;
            end
            init_panel.ds_panel.Position(3) = x-20;
            transition_panel.ds_panel.Position(3) = x-20;
            emission_panel.ds_panel.Position(3) = x-20;

            % help, create and cancel buttons
            help_button = uicontrol(dist_dialog,...
                'Style', 'pushbutton',...
                'String', 'Help',...
                'Position', [10 10 50 20]);
            
            if is_prior
                save_button = uicontrol(dist_dialog,...
                    'Style', 'pushbutton',...
                    'String', 'Save',...
                    'ForegroundColor', [0.0 0.8 0.0],...
                    'Position', [x-120 10 50 20]);
                cancel_button = uicontrol(dist_dialog,...
                    'Style', 'pushbutton',...
                    'String', 'Cancel',...
                    'ForegroundColor', [0.8 0.0 0.0],...
                    'Position', [x-60 10 50 20]);
            else
                ok_button = uicontrol(dist_dialog,...
                    'Style', 'pushbutton',...
                    'String', 'OK',...
                    'ForegroundColor', [0.0 0.8 0.0],...
                    'Position', [x-60 10 50 20]);
            end
            
            function help_action(~, ~)
                disp('TODO help');
            end
            
            function save_action(~, ~)
                model_name = class(obj.workspace.model);
                % emission data
                emis_params = {};
                f1 = fields(emission_panel.ds_params);
                for i=1:size(f1,1)
                    aux1 = getfield(emission_panel.ds_params, f1{i});
                    aux2 = aux1.UserData;
                    emis_params = setfield(emis_params, f1{i}, aux2);
                end
                % duration data
                if strcmp(model_name, 'hsmm')
                    dur_params = {};
                    f1 = fields(duration_panel.ds_params);
                    for i=1:size(f1,1)
                        aux1 = getfield(duration_panel.ds_params, f1{i});
                        aux2 = aux1.UserData;
                        dur_params = setfield(dur_params, f1{i}, aux2);
                    end
                end
                % transition data
                trans_params = {};
                f1 = fields(transition_panel.ds_params);
                for i=1:size(f1,1)
                    aux1 = getfield(transition_panel.ds_params, f1{1});
                    aux2 = aux1.UserData;
                    trans_params = setfield(trans_params, f1{1}, aux2);
                end
                % initial data
                init_params = {};
                f1 = fields(init_panel.ds_params);
                for i=1:size(f1,1)
                    aux1 = getfield(init_panel.ds_params, f1{1});
                    aux2 = aux1.UserData;
                    init_params = setfield(init_params, f1{1}, aux2);
                end
                % put data in the models
                data.emis = emis_params;
                if strcmp(model_name, 'hsmm')
                    data.dur = dur_params;
                end
                data.trans = trans_params;
                data.init = init_params;
                delete(dist_dialog);
            end
            
            function cancel_action(~, ~)
                delete(dist_dialog);
            end
            
            help_button.Callback = @help_action;
            
            if is_prior
                save_button.Callback = @save_action;
                cancel_button.Callback = @cancel_action;
            else
                ok_button.Callback = @cancel_action;
            end

            data = {};
            
            uiwait(dist_dialog);
        end
        
        function data = get_estimation(obj)
            data = {};
            
            est_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 100 240 290],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Parameters Estimation',...
                'numbertitle', 'off',...
                'resize', 'off');
            
            % learning algorithm
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Learning Algorithm:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 260 100 20]);
            alg_idx = find(strcmp({'VB', 'EM'}, obj.workspace.opt.train));
            alg_opts = {'Variational Bayes', 'Expectation Maximization'};
            algorithm_combo = uicontrol(est_dialog,...
                'Style', 'popup',...
                'String', alg_opts,...
                'Position', [110 265 120 20],...
                'Value', alg_idx);
            % Initialization
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Initialization:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 230 100 20]);
            init_idx = find(strcmp({'kmeans', 'random'}, obj.workspace.opt.train));
            init_opts = {'K-means', 'Random'};
            init_combo = uicontrol(est_dialog,...
                'Style', 'popup',...
                'String', init_opts,...
                'Position', [110 235 120 20]);
            km_lab = uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Iterations:',...
                'HorizontalAlignment', 'left',...
                'Position', [240 230 50 20]);
            km_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [300 235 40 20],...
                'String', num2str(obj.workspace.opt.maxiter));
            % repetitions
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Repetitions:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 200 70 20]);
            repetitions_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [110 200 120 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.nrep));
            % tolerance
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Tolerance:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 170 70 20]);
            tolerance_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [110 170 120 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.tol));
            % max number of cycles
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Max cycle:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 140 70 20]);
            max_cycle_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [110 140 120 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.maxcyc));
            % duration
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'Duration:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 110 70 20]);
            dmax_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [110 110 120 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.dmax));
            % # states
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', '# States:',...
                'HorizontalAlignment', 'left',...
                'Position', [10 80 50 20]);
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'min: ',...
                'HorizontalAlignment', 'right',...
                'Position', [80 80 30 20]);
            min_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [110 80 40 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.minstates));
            uicontrol(est_dialog,...
                'Style', 'text',...
                'String', 'max: ',...
                'HorizontalAlignment', 'right',...
                'Position', [160 80 30 20]);
            max_entry = uicontrol(est_dialog,...
                'Style', 'edit',...
                'String', '',...
                'Position', [190 80 40 20],...
                'HorizontalAlignment', 'right',...
                'String', num2str(obj.workspace.opt.maxstates));
            verbose_check = uicontrol(est_dialog,...
                'Style', 'checkbox',...
                'String', 'Verbose',...
                'Position', [10 50 100 20],...
                'Value', strcmp(obj.workspace.opt.verbose, 'yes'));

            % help, create and cancel buttons
            help_button = uicontrol(est_dialog,...
                'Style', 'pushbutton',...
                'String', 'Help',...
                'Position', [10 10 50 20]);
            run_button = uicontrol(est_dialog,...
                'Style', 'pushbutton',...
                'String', 'Run',...
                'ForegroundColor', [0.0 0.8 0.0],...
                'Position', [120 10 50 20]);
            cancel_button = uicontrol(est_dialog,...
                'Style', 'pushbutton',...
                'String', 'Cancel',...
                'ForegroundColor', [0.8 0.0 0.0],...
                'Position', [180 10 50 20]);
            
            function kmeans_options(src, ev)
                if strcmp(init_opts(init_combo.Value), 'K-means')
                    km_lab.Visible = 'on';
                    km_entry.Visible = 'on';
                    run_button.Position(1) = run_button.Position(1) + 110;
                    cancel_button.Position(1) = cancel_button.Position(1) + 110;
                    est_dialog.Position(3) = est_dialog.Position(3) + 110;
                else
                    km_lab.Visible = 'off';
                    km_entry.Visible = 'off';
                    run_button.Position(1) = run_button.Position(1) - 110;
                    cancel_button.Position(1) = cancel_button.Position(1) - 110;
                    est_dialog.Position(3) = est_dialog.Position(3) - 110;
                end
            end
            
            function help_action(src, ev)
                disp('TODO help');
            end
            
            function run_action(src, ev)
                % get info
                selected_alg = alg_opts(algorithm_combo.Value);
                selected_init = init_opts(init_combo.Value);
                max_iter = str2num(km_entry.String);
                n_repetitions = str2num(repetitions_entry.String);
                tolerance = str2num(tolerance_entry.String);
                max_cycle = str2num(max_cycle_entry.String);
                dmax = str2num(dmax_entry.String);
                min_states = str2num(min_entry.String);
                max_states = str2num(max_entry.String);
                verbose = verbose_check.Value;
                
                % validate values are numbers
                
                % store info
                data.learning_algorithm = selected_alg{1};
                data.initialization = selected_init{1};
                data.maxiter = max_iter;
                data.n_repetitions = n_repetitions;
                data.tolerance= tolerance;
                data.max_cycles = max_cycle;
                data.dmax = dmax;
                data.n_states = {min_states, max_states};
                data.verbose = verbose;
                % close the dialog
                delete(est_dialog);
            end
            
            function cancel_action(src, ev)
                delete(est_dialog);
            end
            
            kmeans_options({},{});
            init_combo.Callback = @kmeans_options;
            help_button.Callback = @help_action;
            run_button.Callback = @run_action;
            cancel_button.Callback = @cancel_action;

            uiwait(est_dialog);
        end
        
        function data = get_generation(obj)
            model_name = class(obj.workspace.model);
            editable_params = 1;
            mean_based_params = {};
            n_states = obj.workspace.model.nstates;
            
            function new_values=get_params(option)
                % previous values
                previous.emis = obj.workspace.model.emis_model.parsampl;
                previous.trans = obj.workspace.model.trans_model.parsampl; 
                previous.in = obj.workspace.model.in_model.parsampl;
                if strcmp(model_name, 'hsmm')
                    previous.dur = obj.workspace.model.dur_model.parsampl;
                end
                % calculate
                obj.workspace.model.init(option);
                % store
                new_values.emis = obj.workspace.model.emis_model.parsampl;
                new_values.trans = obj.workspace.model.trans_model.parsampl; 
                new_values.in = obj.workspace.model.in_model.parsampl;
                if strcmp(model_name, 'hsmm')
                    new_values.dur = obj.workspace.model.dur_model.parsampl;
                end
                % get distribution model names
                new_values.models.emis = class(obj.workspace.model.emis_model);
                new_values.models.emis = new_values.models.emis(strfind(new_values.models.emis, '.')+1:size(new_values.models.emis, 2));
                new_values.models.trans = class(obj.workspace.model.trans_model);
                new_values.models.trans = new_values.models.trans(strfind(new_values.models.trans, '.')+1:size(new_values.models.trans, 2));
                new_values.models.in = class(obj.workspace.model.in_model);
                new_values.models.in = new_values.models.in(strfind(new_values.models.in, '.')+1:size(new_values.models.in, 2));
                if strcmp(model_name, 'hsmm')
                    new_values.models.dur = class(obj.workspace.model.dur_model);
                    new_values.models.dur = new_values.models.dur(strfind(new_values.models.dur, '.')+1:size(new_values.models.dur, 2));
                end
                % set old parameters
                obj.workspace.model.emis_model.parsampl = previous.emis;
                obj.workspace.model.trans_model.parsampl = previous.trans; 
                obj.workspace.model.in_model.parsampl = previous.in;
                if strcmp(model_name, 'hsmm')
                    obj.workspace.model.dur_model.parsampl = previous.dur;
                end
            end
            
            user_defined_params = get_params(4);

            function modify_cell(src, ev)
                % nobody generate this event so skip
                if isempty(ev.Indices)
                    return
                end
                
                col = ev.Indices(2); % n_states
                row = ev.Indices(1); % parameter name
                
                text = 'weiv';
                if editable_params
                    text = 'tide';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;
                text = 'view';
                if editable_params
                    text = 'edit';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;

                row_name = src.RowName{row};
                the_model = src.UserData;
                sub_dialog = figure(...
                    'units', 'pixels',...
                    'Position', [100 100 182 166],...
                    'Toolbar', 'none',...
                    'Menubar', 'none',...
                    'Name', '',...
                    'numbertitle', 'off',...
                    'resize', 'off');
               
                f1 = getfield(the_model, row_name);
                f1 = f1{col};
                cw = num2cell(40*ones(1, size(f1, 2)));
                ed = false(1, size(f1, 2));
                if editable_params
                    ed = true(1, size(f1, 2));
                end

                my_table = uitable(sub_dialog,...
                    'ColumnEditable', ed,...
                    'Data', f1,...
                    'ColumnWidth', cw,...
                    'Position', [10 40 162 86]);

                the_label = uicontrol(sub_dialog,...
                    'Position', [10 136 162 20],...
                    'Style', 'text',...
                    'HorizontalAlignment', 'left',...
                    'String', ['State N°' num2str(col) ' / parameter: ' row_name]);

                function load_action(~, ~)
                    % retrieve var from global workspace
                    vars = evalin('base', 'who()');
                    % ask the user to select one
                    [indx,tf] = listdlg('PromptString', 'Select Data:',...
                        'SelectionMode', 'single',...
                        'ListString', vars);
                    if ~tf
                        % cancel the loading by close or press cancel
                        return;
                    end
                    % get the value
                    value = evalin('base', vars{indx});
                    my_table.Data = value;
                end
                    
                function ok_action(~, ~)
                    new_data = getfield(the_model, row_name);
                    new_data{col} = my_table.Data;
                    the_model = setfield(the_model, row_name, new_data);
                    src.UserData = the_model;
                    delete(sub_dialog);
                end
                
                function cancel_action(~, ~)
                    delete(sub_dialog);
                end

                if editable_params
                    load_button = uicontrol(sub_dialog,...
                        'Position', [122 136 50 20],...
                        'Style', 'pushbutton',...
                        'String', 'load');

                    load_button.Callback = @load_action;
                    
                    the_label.Position(2) = the_label.Position(2)+30;
                    sub_dialog.Position(4) = sub_dialog.Position(4)+30;
                    
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [62 10 50 20]);
                    cancel_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'Cancel',...
                        'ForegroundColor', [0.8 0.0 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @ok_action;
                    cancel_button.Callback = @cancel_action;
                else
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @cancel_action;
                end
            end
                            
            function modify_trans_in(src, ev)
                the_model = getfield(user_defined_params, src.UserData);
                name = 'Initial Probabilitiy';
                if strcmp(src.UserData, 'trans')
                    name = 'Transitions Matrix';
                end
                    
                sub_dialog = figure(...
                    'units', 'pixels',...
                    'Position', [100 100 182 166],...
                    'Toolbar', 'none',...
                    'Menubar', 'none',...
                    'Name', name,...
                    'numbertitle', 'off',...
                    'resize', 'off');
                
                the_label = uicontrol(sub_dialog,...
                    'Position', [10 136 162 20],...
                    'Style', 'text',...
                    'HorizontalAlignment', 'left',...
                    'String', name);

                cw = num2cell(40*ones(1, size(the_model, 2)));
                ed = true(1, size(the_model, 2));
                if ~editable_params
                    ed = false(1, size(the_model, 2));
                end

                my_table = uitable(sub_dialog,...
                    'ColumnEditable', ed,...
                    'Data', the_model,...
                    'ColumnWidth', cw,...
                    'Position', [10 40 162 86]);

                function ok_action(~, ~)
                    user_defined_params = setfield(user_defined_params, src.UserData, my_table.Data);
                    delete(sub_dialog);
                end
                
                function cancel_action(~, ~)
                    delete(sub_dialog);
                end

                function load_action(~, ~)
                    % retrieve var from global workspace
                    vars = evalin('base', 'who()');
                    % ask the user to select one
                    [indx,tf] = listdlg('PromptString', 'Select Data:',...
                        'SelectionMode', 'single',...
                        'ListString', vars);
                    if ~tf
                        % cancel the loading by close or press cancel
                        return;
                    end
                    % get the value
                    value = evalin('base', vars{indx});
                    my_table.Data = value;
                end
                    
                if editable_params
                        load_button = uicontrol(sub_dialog,...
                        'Position', [122 136 50 20],...
                        'Style', 'pushbutton',...
                        'String', 'load');

                    load_button.Callback = @load_action;
                    
                    the_label.Position(2) = the_label.Position(2)+30;
                    sub_dialog.Position(4) = sub_dialog.Position(4)+30;

                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [62 10 50 20]);
                    cancel_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'Cancel',...
                        'ForegroundColor', [0.8 0.0 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @ok_action;
                    cancel_button.Callback = @cancel_action;
                else
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @cancel_action;
                end
            end
                            
            data = {};

            gen_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 100 350 480],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Generate from Model',...
                'numbertitle', 'off',...
                'resize', 'off');

            y = 40;
            if strcmp(model_name, 'hsmm')
                % duration model data 
                f_dur = fields(obj.workspace.model.dur_model.parsampl);
                [dur_data{1:size(f_dur,1),1:n_states}] = deal('edit');
                [cw{1:n_states}] = deal(30);
                duration_panel = uipanel(gen_dialog,...
                    'Title', 'Duration Model',...
                    'units', 'pixels',...
                    'Position', [10 y 330 140]);
                duration_model_label = uicontrol(duration_panel,...
                    'Position', [10 100 300 20],...
                    'Style', 'text',...
                    'HorizontalAlignment', 'left',...
                    'String', user_defined_params.models.dur);
                duration_table = uitable(duration_panel,...
                    'RowName', f_dur,...
                    'Data', dur_data,...
                    'ColumnWidth', cw,...
                    'Position', [10 10 310 90],...
                    'CellSelectionCallback', @modify_cell,...
                    'UserData', obj.workspace.model.dur_model.parsampl);
            y = y + 150;
            end
            
            % emission model data 
            f_emis = fields(obj.workspace.model.emis_model.parsampl);
            [emis_data{1:size(f_emis,1),1:n_states}] = deal('edit');
            [cw{1:n_states}] = deal(30);
            emission_panel = uipanel(gen_dialog,...
                'Title', 'Emission Model',...
                'units', 'pixels',...
                'Position', [10 y 330 140]);
            emission_model_label = uicontrol(emission_panel,...
                'Position', [10 100 300 20],...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'String', user_defined_params.models.emis);
            emis_table = uitable(emission_panel,...
                'RowName', {'mean', 'prec'},...
                'Data', emis_data,...
                'ColumnWidth', cw,...
                'Position', [10 10 310 90],...
                'CellSelectionCallback', @modify_cell,...
                'UserData', obj.workspace.model.emis_model.parsampl);

            y = y + 150;
            % transition matrix
            transition_label = uicontrol(gen_dialog,...
                'Position', [20 y 60 40],...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'String', 'Transition Matrix');
            transition_button = uicontrol(gen_dialog,...
                'Style', 'pushbutton',...
                'String', 'edit',...
                'Position', [90 y+20 60 20],...
                'Callback', @modify_trans_in,...
                'UserData', 'trans');
            
            % initial conditions
            initial_label = uicontrol(gen_dialog,...
                'Position', [170 y 60 40],...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'String', 'Initial Probability');
            initial_button = uicontrol(gen_dialog,...
                'Style', 'pushbutton',...
                'String', 'edit',...
                'Position', [240 y+20 60 20],...
                'Callback', @modify_trans_in,...
                'UserData', 'in');
            
            y = y + 50;
            % parameters 
            generation_based_on = uibuttongroup(gen_dialog,...
                'Title', 'Parameters',...
                'units', 'pixels',...
                'Position', [10 y 300 50]);
            user_defined = uicontrol(generation_based_on,...
                'Style', 'radiobutton',...
                'Position', [20 10 110 20],...
                'String', 'User Defined');
            mean_based = uicontrol(generation_based_on,...
                'Style', 'radiobutton',...
                'Position', [150 10 110 20],...
                'String', 'Posterior Values');

            y = y + 60;
            % data amount
            uicontrol(gen_dialog,...
                'Position', [10 y 60 20],...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'String', 'Data Size');
            data_amount_entry = uicontrol(gen_dialog,...
                'Position', [70 y 30 20],...
                'Style', 'edit',...
                'HorizontalAlignment', 'left');
            
            y = y + 30;
            gen_dialog.Position(4) = y;
            
            % help, create and cancel buttons
            help_button = uicontrol(gen_dialog,...
                'Style', 'pushbutton',...
                'String', 'Help',...
                'Position', [10 10 50 20]);
            generate_button = uicontrol(gen_dialog,...
                'Style', 'pushbutton',...
                'String', 'Generate',...
                'ForegroundColor', [0.0 0.8 0.0],...
                'Position', [230 10 50 20]);
            cancel_button = uicontrol(gen_dialog,...
                'Style', 'pushbutton',...
                'String', 'Cancel',...
                'ForegroundColor', [0.8 0.0 0.0],...
                'Position', [290 10 50 20]);

            function mean_based_action(src, ~)
                % ask if model created and if it was trained
                if isempty(mean_based_params)
                    mean_based_params = get_params(1);
                end
                user_defined_params = mean_based_params;
                editable_params = 0;
                [aux1{1:size(emis_table.Data,1),1:size(emis_table.Data,2)}] = deal('view');
                emis_table.Data = aux1;
                [aux2{1:size(duration_table.Data,1),1:size(duration_table.Data,2)}] = deal('view');
                duration_table.Data = aux2;
                transition_button.String = 'view';
                initial_button.String = 'view';
            end
            
            function user_defined_action(~, ~)
                editable_params = 1;
                [aux1{1:size(emis_table.Data,1),1:size(emis_table.Data,2)}] = deal('edit');
                emis_table.Data = aux1;
                [aux2{1:size(duration_table.Data,1),1:size(duration_table.Data,2)}] = deal('edit');
                duration_table.Data = aux2;
                transition_button.String = 'edit';
                initial_button.String = 'edit';
            end
            
            function help_action(~, ~)
                disp('TODO help');
            end
            
            function generate_action(~, ~)
                % get info
                selected_model = generation_based_on.SelectedObject.String;
                n_data = str2num(data_amount_entry.String);
                
                % validate n_data is number
                
                data.n = n_data;
                
                % validate matrixes # sum( sum( isnan(M) ) ) == 0
                data.method = 'mean_based';
                if strcmp(selected_model, 'User Defined')
                    data.method = 'user defined';
                end
                data.parameters = user_defined_params;
                    
                delete(gen_dialog);
            end
            
            function cancel_action(src, ev)
                delete(gen_dialog);
            end
            
            mean_based.Callback = @mean_based_action;
            user_defined.Callback = @user_defined_action;
            help_button.Callback = @help_action;
            generate_button.Callback = @generate_action;
            cancel_button.Callback = @cancel_action;

            uiwait(gen_dialog);
        end
        
        function data = get_sequence(~)
            data = {};

            sequence_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 100 240 70],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Most Probable Sequence',...
                'numbertitle', 'off',...
                'resize', 'off');
            sequence_file_entry = uicontrol(sequence_dialog,...
                'Style', 'edit',...
                'Position', [10 40 150 20],...
                'String', '',...
                'HorizontalAlignment', 'left',...
                'Enable', 'inactive');
            sequence_browse = uicontrol(sequence_dialog,...
                'Style', 'pushbutton',...
                'String', 'Browse',...
                'Position', [170 40 60 20]);

            % help, get and cancel buttons
            help_button = uicontrol(sequence_dialog,...
                'Style', 'pushbutton',...
                'String', 'Help',...
                'Position', [10 10 50 20]);
            get_button = uicontrol(sequence_dialog,...
                'Style', 'pushbutton',...
                'String', 'Get',...
                'ForegroundColor', [0.0 0.8 0.0],...
                'Position', [120 10 50 20]);
            cancel_button = uicontrol(sequence_dialog,...
                'Style', 'pushbutton',...
                'String', 'Cancel',...
                'ForegroundColor', [0.8 0.0 0.0],...
                'Position', [180 10 50 20]);

            function browse_action(~, ~)
                % ask for file
                [selected_file, path] = uigetfile({'*.*',  'All Files (*.*)'});
                % if a file is selected
                if selected_file ~= 0
                    sequence_file_entry.String = [path selected_file];
                end
            end
            
            function help_action(~, ~)
                disp('TODO help');
            end
            
            function get_action(~, ~)
                filename = sequence_file_entry.String;
                if isempty(filename)
                    disp('No hay archvio de datos')
                    return
                end
                % read data
                sequence_data = load(filename);
                % if it has fields get the first one
                if isstruct(sequence_data)
                    f = fields(sequence_data);
                    if size(f,1)>1
                        disp(['more than one field in the struct, using "' f{1} '"']);
                    end
                    sequence_data = getfield(sequence_data, f{1});
                end
                data.sequence_data = sequence_data;
                delete(sequence_dialog);
            end
            
            function cancel_action(~, ~)
                delete(sequence_dialog);
            end
            
            sequence_browse.Callback = @browse_action;
            help_button.Callback = @help_action;
            get_button.Callback = @get_action;
            cancel_button.Callback = @cancel_action;

            uiwait(sequence_dialog);
        end
        
        function data = get_select_vars(obj, btn_txt)
            data = {};
            checks = {};

            function select(src, ~)
                selected = fields(checks);
                for i=1:size(selected,1)
                    disp('uno');
                    disp(checks);
                    disp('dos');
                    disp(selected(i));
                    disp('tres');
                    check = getfield(checks, selected{i});
                    check.Value = 1;
                end
            end
            
            select_dialog = figure(...
                'units', 'pixels',...
                'Position', [100 100 150 10],...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'Name', 'Variables',...
                'numbertitle', 'off',...
                'resize', 'off');
            
            y = 40;
            % opt values
            if ~isempty(obj.workspace.opt)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Options (opt)',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['opt']);
                checks = setfield(checks, 'opt', aux);
                y = y + 30;
            end
            % viterbi sequence
            if ~isempty(obj.workspace.viterbi_results)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Viterbi Sequence',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['viterbi']);
                checks = setfield(checks, 'viterbi', aux);
                y = y + 30;
            end
            % generated data
            if ~isempty(obj.workspace.generated_data)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Generated Data',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['generated']);
                checks = setfield(checks, 'generated', aux);
                y = y + 30;
            end
            % decoded data
            if ~isempty(obj.workspace.decode_results)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Decode Results',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['decode']);
                checks = setfield(checks, 'decode', aux);
                y = y + 30;
            end
            % results
            if ~isempty(obj.workspace.training_results)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Training Results',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['results']);
                checks = setfield(checks, 'results', aux);
                y = y + 30;
            end
            % model
            if ~isempty(obj.workspace.model)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Model',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['model']);
                checks = setfield(checks, 'model', aux);
                y = y + 30;
            end
            % training data
            if ~isempty(obj.workspace.data)
                aux = uicontrol(select_dialog,...
                    'Style', 'checkbox',...
                    'String', 'Loaded Data',...
                    'Position', [25 y 110 20],...
                    'Value', 0,...
                    'UserData', ['data']);
                checks = setfield(checks, 'data', aux);
                y = y + 30;
            end

            uicontrol(select_dialog,...
                'Style', 'pushbutton',...
                'String', 'Select All',...
                'Position', [45 y 60 20],...
                'Callback', @select);
            
            select_dialog.Position(4) = y+30;
            
            % ok and cancel buttons
            ok_button = uicontrol(select_dialog,...
                'Style', 'pushbutton',...
                'String', btn_txt,...
                'ForegroundColor', [0.0 0.8 0.0],...
                'Position', [30 10 50 20]);
            cancel_button = uicontrol(select_dialog,...
                'Style', 'pushbutton',...
                'String', 'Cancel',...
                'ForegroundColor', [0.8 0.0 0.0],...
                'Position', [90 10 50 20]);

            function ok_action(~, ~)
                aux = fields(checks);
                for i=1:size(aux,1)
                    check = getfield(checks, aux{i});
                    data = setfield(data, aux{i}, check.Value);
                end
                delete(select_dialog);
            end
            
            function cancel_action(~, ~)
                delete(select_dialog);
            end
            
            ok_button.Callback = @ok_action;
            cancel_button.Callback = @cancel_action;

            uiwait(select_dialog);
        end
        
        % check exists opt and ask to create it
        function data = check_opt(obj)
            data = 0;
            
            if isempty(obj.workspace.opt)
                choice = questdlg({'"opt" variable does not exist,', 'Do you want to create it by default?'},...
                    'Missing options',...
                    'Yes', 'No', 'Yes');
                if strcmp(choice, 'Yes')
                    obj.load_opt();
                    data = 1;
                end
            else
                data = 1;
                return;
            end
        end
        
        % emission and duration distribution panel creation
        function g = get_emission_duration_panel(~, parent, name, model, is_prior)
            function modify_cell(src, ev, is_prior, cbox)
                is_editable = is_prior && (cbox.Value>1);

                % nobody generate this event so skip
                if isempty(ev.Indices)
                    return
                end
                
                col = ev.Indices(2); % n_states
                row = ev.Indices(1); % parameter name
                
                text = 'weiv';
                if is_editable
                    text = 'tide';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;
                text = 'view';
                if is_editable
                    text = 'edit';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;

                row_name = src.RowName{row};
                the_model = src.UserData;
                sub_dialog = figure(...
                    'units', 'pixels',...
                    'Position', [100 100 182 166],...
                    'Toolbar', 'none',...
                    'Menubar', 'none',...
                    'Name', '',...
                    'numbertitle', 'off',...
                    'resize', 'off');
               
                f1 = getfield(the_model{col}, row_name);
                cw = num2cell(40*ones(1, size(f1, 2)));
                ed = false(1, size(f1, 2));
                if is_editable
                    ed = true(1, size(f1, 2));
                end

                my_table = uitable(sub_dialog,...
                    'ColumnEditable', ed,...
                    'Data', f1,...
                    'ColumnWidth', cw,...
                    'Position', [10 40 162 86]);

                the_label = uicontrol(sub_dialog,...
                    'Position', [10 136 162 20],...
                    'Style', 'text',...
                    'HorizontalAlignment', 'left',...
                    'String', ['State N°' num2str(col) ' / parameter: ' row_name]);

                function load_action(~, ~)
                    % retrieve var from global workspace
                    vars = evalin('base', 'who()');
                    % ask the user to select one
                    [indx,tf] = listdlg('PromptString', 'Select Data:',...
                        'SelectionMode', 'single',...
                        'ListString', vars);
                    if ~tf
                        % cancel the loading by close or press cancel
                        return;
                    end
                    % get the value
                    value = evalin('base', vars{indx});
                    my_table.Data = value;
                end
                    
                function ok_action(~, ~)
                    the_model{col} = setfield(the_model{col}, row_name, my_table.Data);
                    src.UserData = the_model;
                    delete(sub_dialog);
                end
                
                function cancel_action(~, ~)
                    delete(sub_dialog);
                end

                if is_editable
                    load_button = uicontrol(sub_dialog,...
                        'Position', [122 136 50 20],...
                        'Style', 'pushbutton',...
                        'String', 'load');

                    load_button.Callback = @load_action;
                    
                    the_label.Position(2) = the_label.Position(2)+30;
                    sub_dialog.Position(4) = sub_dialog.Position(4)+30;
                    
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [62 10 50 20]);
                    cancel_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'Cancel',...
                        'ForegroundColor', [0.8 0.0 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @ok_action;
                    cancel_button.Callback = @cancel_action;
                else
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @cancel_action;
                end
            end
            
            % model name
            m_name = class(model);
            n = size(m_name, 2);
            i = strfind(m_name, '.');
            m_name = m_name(i+1:n);
            % distribution
            g.ds_panel = uipanel(parent,...
                'units', 'pixels',...
                'Title', [name ' Model'],...
                'FontWeight', 'bold',...
                'Position', [0 0 500 135]);
            distribution_model = model.prior;
            if ~is_prior
                distribution_model = model.posterior;
            end
            
            g.ds_name = uicontrol(g.ds_panel,...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'Position', [50 95 250 20],...
                'String', m_name);
            x = 10;
            if is_prior
                g.ds_combo = uicontrol(g.ds_panel,...
                    'Style', 'popup',...
                    'HorizontalAlignment', 'left',...
                    'Position', [x 70 100 25],...
                    'String', {'Non Informative', 'User Defined'});
                x = x + 110;
            else
                g.ds_combo = {};
            end

            % fields of the model
            params = fields(distribution_model);
            % visit every field
            g.ds_params = {};
            for i=1:size(params,1)
                key = params{i};
                value = getfield(distribution_model, key);
                my_panel = uipanel(g.ds_panel,...
                    'Title', key,...
                    'units', 'pixels',...
                    'Position', [x 10 180 90]);
                
                % number of states in the model
                n_states = size(value, 2);
                % parameters of states (same for everyone)
                state_params = fields(value{1});
                % matrix of edit string
                [model_data{1:size(state_params,1),1:n_states}] = deal('view');
                % width for columns
                [cw{1:n_states}] = deal(30);
                % finally the table
                my_table = uitable(my_panel,...
                    'RowName', state_params,...
                    'Data', model_data,...
                    'ColumnWidth', cw,...
                    'Position', [10 10 160 60],...
                    'CellSelectionCallback', {@modify_cell, is_prior, g.ds_combo},...
                    'UserData', value);

                g.ds_params = setfield(g.ds_params, key, my_table);
                % move pointer
                x = x+190;
            end
            
            g.ds_panel.Position(3) = x;
        end
        
        % emission and duration distribution panel creation
        function g = get_transition_initial_panel(~, parent, name, model, is_prior)
            function modify_cell(src, ev, is_prior, cbox)
                is_editable = is_prior && (cbox.Value>1);

                % nobody generate this event so skip
                if isempty(ev.Indices)
                    return
                end
                
                col = ev.Indices(2); % n_states
                row = ev.Indices(1); % parameter name
                
                text = 'weiv';
                if is_editable
                    text = 'tide';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;
                text = 'view';
                if is_editable
                    text = 'edit';
                end
                [aux{1:size(src.Data,1),1:size(src.Data,2)}] = deal(text);
                src.Data = aux;

                row_name = src.RowName{row};
                the_model = src.UserData;
                sub_dialog = figure(...
                    'units', 'pixels',...
                    'Position', [100 100 182 166],...
                    'Toolbar', 'none',...
                    'Menubar', 'none',...
                    'Name', '',...
                    'numbertitle', 'off',...
                    'resize', 'off');
               
                f1 = getfield(the_model, row_name);
                cw = num2cell(40*ones(1, size(f1, 2)));
                ed = false(1, size(f1, 2));
                if is_editable
                    ed = true(1, size(f1, 2));
                end

                my_table = uitable(sub_dialog,...
                    'ColumnEditable', ed,...
                    'Data', f1,...
                    'ColumnWidth', cw,...
                    'Position', [10 40 162 86]);

                the_label = uicontrol(sub_dialog,...
                    'Position', [10 136 162 20],...
                    'Style', 'text',...
                    'HorizontalAlignment', 'left',...
                    'String', ['parameter: ' row_name]);

                function load_action(~, ~)
                    % retrieve var from global workspace
                    vars = evalin('base', 'who()');
                    % ask the user to select one
                    [indx,tf] = listdlg('PromptString', 'Select Data:',...
                        'SelectionMode', 'single',...
                        'ListString', vars);
                    if ~tf
                        % cancel the loading by close or press cancel
                        return;
                    end
                    % get the value
                    value = evalin('base', vars{indx});
                    my_table.Data = value;
                end
                    
                function ok_action(~, ~)
                    the_model = setfield(the_model, row_name, my_table.Data);
                    src.UserData = the_model;
                    delete(sub_dialog);
                end
                
                function cancel_action(~, ~)
                    delete(sub_dialog);
                end

                if is_editable
                    load_button = uicontrol(sub_dialog,...
                        'Position', [122 136 50 20],...
                        'Style', 'pushbutton',...
                        'String', 'load');

                    load_button.Callback = @load_action;
                    
                    the_label.Position(2) = the_label.Position(2)+30;
                    sub_dialog.Position(4) = sub_dialog.Position(4)+30;
                    
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [62 10 50 20]);
                    cancel_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'Cancel',...
                        'ForegroundColor', [0.8 0.0 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @ok_action;
                    cancel_button.Callback = @cancel_action;
                else
                    ok_button = uicontrol(sub_dialog,...
                        'Style', 'pushbutton',...
                        'String', 'OK',...
                        'ForegroundColor', [0.0 0.8 0.0],...
                        'Position', [122 10 50 20]);
                    ok_button.Callback = @cancel_action;
                end
            end
            
            % model name
            m_name = class(model);
            n = size(m_name, 2);
            i = strfind(m_name, '.');
            m_name = m_name(i+1:n);
            % distribution
            g.ds_panel = uipanel(parent,...
                'units', 'pixels',...
                'Title', [name ' Model'],...
                'FontWeight', 'bold',...
                'Position', [0 0 500 135]);
            distribution_model = model.prior;
            if ~is_prior
                distribution_model = model.posterior;
            end
            
            g.ds_name = uicontrol(g.ds_panel,...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'Position', [50 95 250 20],...
                'String', m_name);
            x = 10;
            if is_prior
                g.ds_combo = uicontrol(g.ds_panel,...
                    'Style', 'popup',...
                    'HorizontalAlignment', 'left',...
                    'Position', [x 70 100 25],...
                    'String', {'Non Informative', 'User Defined'});
                x = x + 110;
            else
                g.ds_combo = {};
            end

            % fields of the model
            params = fields(distribution_model);
            % visit every field
            g.ds_params = {};
            for i=1:size(params,1)
                key = params{i};
                value = getfield(distribution_model, key);
                my_panel = uipanel(g.ds_panel,...
                    'Title', key,...
                    'units', 'pixels',...
                    'Position', [x 10 180 90]);
                
                % parameters of states (same for everyone)
                state_params = fields(value);
                % matrix of edit string
                [model_data{1:size(state_params,1),1}] = deal('view');
                % width for columns
                cw = {30};
                % finally the table
                my_table = uitable(my_panel,...
                    'RowName', state_params,...
                    'Data', model_data,...
                    'ColumnWidth', cw,...
                    'Position', [10 10 160 60],...
                    'CellSelectionCallback', {@modify_cell, is_prior, g.ds_combo},...
                    'ButtonDownFcn', {@hola},...
                    'UserData', value);

                g.ds_params = setfield(g.ds_params, key, my_table);
                % move pointer
                x = x+190;
            end
            
            g.ds_panel.Position(3) = x;
        end
        
        % refresh display of workspace variables
        function show_workspace(obj)
            % if there is no data at all
            at_least_one = 0;
            
            if ~isempty(obj.workspace.data)
                at_least_one = 1;
                % panel color and text
                obj.gui.data_panel.ForegroundColor = [0.0 0.8 0.0];
                obj.gui.data_panel.Title = ['Name : [ ' obj.workspace.metadata.name ' ]'];
                % labels
                obj.gui.data_filename_label.ForegroundColor = [0.0 0.0 0.0];
                obj.gui.data_filename_value.ForegroundColor = [0.0 0.0 0.8];
                pieces = strsplit(obj.workspace.metadata.filename, '\');
                obj.gui.data_filename_value.String = pieces(size(pieces,2));
                obj.gui.data_dimension_label.ForegroundColor = [0.0 0.0 0.0];
                obj.gui.data_dimension_value.ForegroundColor = [0.0 0.0 0.8];
                obj.gui.data_dimension_value.String = num2str(obj.workspace.metadata.dimension);
                obj.gui.data_length_label.ForegroundColor = [0.0 0.0 0.0];
                obj.gui.data_length_value.ForegroundColor = [0.0 0.0 0.8];
                obj.gui.data_length_value.String = num2str(obj.workspace.metadata.length);
            else
                % panel color and text
                obj.gui.data_panel.ForegroundColor = [0.8 0.0 0.0];
                obj.gui.data_panel.Title = 'Data not Loaded';
                % labels
                obj.gui.data_filename_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.data_filename_value.String = '';
                obj.gui.data_dimension_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.data_dimension_value.String = '';
                obj.gui.data_length_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.data_length_value.String = '';
            end

            if ~isempty(obj.workspace.model)
                at_least_one = 1;
                % panel color and text
                obj.gui.model_panel.ForegroundColor = [0.0 0.8 0.0];
                obj.gui.model_panel.Title = ['Model [ ' upper(class(obj.workspace.model)) ' ]'];
                % labels
                obj.gui.prior_label.ForegroundColor = [0.0 0.0 0.0];
                obj.gui.prior_value.ForegroundColor = [0.0 0.8 0.0];
                obj.gui.prior_value.String = 'CREATED';
                obj.gui.posterior_label.ForegroundColor = [0.0 0.0 0.0];
                if obj.workspace.model.emis_model.posteriorfull
                    obj.gui.posterior_value.ForegroundColor = [0.0 0.8 0.0];
                    obj.gui.posterior_value.String = 'CREATED';
                else
                    obj.gui.posterior_value.ForegroundColor = [0.8 0.0 0.0];
                    obj.gui.posterior_value.String = 'NOT CREATED';
                end
                obj.gui.parsampl_label.ForegroundColor = [0.0 0.0 0.0];
                f = fields(obj.workspace.model.emis_model.parsampl);
                if ~isempty(getfield(obj.workspace.model.emis_model.parsampl, f{1}))
                    obj.gui.parsampl_value.ForegroundColor = [0.0 0.8 0.0];
                    obj.gui.parsampl_value.String = 'CREATED';
                else
                    obj.gui.parsampl_value.ForegroundColor = [0.8 0.0 0.0];
                    obj.gui.parsampl_value.String = 'NOT CREATED';
                end
                % # states
                obj.gui.nstates_label.ForegroundColor = [0.0 0.0 0.0];
                if obj.workspace.model.nstates > 0
                    obj.gui.nstates_value.ForegroundColor = [0.0 0.8 0.0];
                    obj.gui.nstates_value.String = num2str(obj.workspace.model.nstates);
                else
                    obj.gui.nstates_value.ForegroundColor = [0.8 0.0 0.0];
                    obj.gui.nstates_value.String = 'undefined';
                end

            else
                % panel color and text
                obj.gui.model_panel.ForegroundColor = [0.8 0.0 0.0];
                obj.gui.model_panel.Title = 'Model not Created';
                % labels
                obj.gui.prior_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.prior_value.String = '';
                obj.gui.posterior_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.posterior_value.String = '';
                obj.gui.parsampl_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.parsampl_value.String = '';
                obj.gui.nstates_label.ForegroundColor = [0.5 0.5 0.5];
                obj.gui.nstates_value.String = '';
            end
            
            if ~at_least_one
                obj.gui.tab_status.ForegroundColor = [0.8 0.0 0.0];
            else
                obj.gui.tab_status.ForegroundColor = [0.0 0.8 0.0];
            end
        end
        
        function classes_list=classes_ls(~, path)
            complete_path = ['+' path];
            elements = ls(complete_path);
            classes_list = {};
            for e=3:size(elements, 1)
                a = strtrim(elements(e,:));
                if strcmp(a(size(a,2)-1:size(a,2)), '.m')
                    b = a(1:size(a,2)-2);
                    classes_list = [classes_list b];
                end
            end
        end
    
        function set_status_bar(obj, msj)
            obj.gui.status_bar.String = msj;
        end

        function menu_enable_state(obj)
            ti_data = ~isempty(obj.workspace.data);
            ti_mod = ~isempty(obj.workspace.model);
            ti_train = ~isempty(obj.workspace.training_results);
            ti_gen = ~isempty(obj.workspace.generated_data);
            ti_seq = ~isempty(obj.workspace.viterbi_results);
            ti_dec = ~isempty(obj.workspace.decode_results);
            ti_ws = (ti_data || ti_mod || ti_train || ti_gen || ti_seq || ti_dec);
            
            % export data
            if ti_data
                obj.gui.export_menu.Enable = 'on';
            else
                obj.gui.export_menu.Enable = 'off';
            end
            % save and clear workspace
            if ti_ws
                obj.gui.save_workspace_menu.Enable = 'on';
                obj.gui.save_as_workspace_menu.Enable = 'on';
                obj.gui.clear_workspace_menu.Enable = 'on';
            else
                obj.gui.save_workspace_menu.Enable = 'off';
                obj.gui.save_as_workspace_menu.Enable = 'off';
                obj.gui.clear_workspace_menu.Enable = 'off';
            end            
            % prior
            if ti_mod
                obj.gui.prior_dist_menu.Enable = 'on';
            else
                obj.gui.prior_dist_menu.Enable = 'off';
            end            
            % posterior and generate
            if ti_train
                obj.gui.posterior_dist_menu.Enable = 'on';
                obj.gui.generate_data_menu.Enable = 'on';
            else
                obj.gui.posterior_dist_menu.Enable = 'off';
                obj.gui.generate_data_menu.Enable = 'off';
            end            
            % train model
            if ti_mod && ti_data
                obj.gui.train_model_menu.Enable = 'on';
            else
                obj.gui.train_model_menu.Enable = 'off';
            end            
            % decode, viterbi
            if ti_train && ti_data
                obj.gui.data_decode_menu.Enable = 'on';
                obj.gui.sequence_estimation_menu.Enable = 'on';
            else
                obj.gui.data_decode_menu.Enable = 'of';
                obj.gui.sequence_estimation_menu.Enable = 'off';
            end            
            % plots
            if ti_seq
                obj.gui.plot_sequence_menu.Enable = 'on';
                obj.gui.plot_occupancy_menu.Enable = 'on';
                obj.gui.plot_histogram_menu.Enable = 'on';
            else
                obj.gui.plot_sequence_menu.Enable = 'off';
                obj.gui.plot_occupancy_menu.Enable = 'off';
                obj.gui.plot_histogram_menu.Enable = 'off';
            end            
        end
    end
end