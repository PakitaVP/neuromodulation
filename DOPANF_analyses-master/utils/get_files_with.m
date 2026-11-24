function relevant_files = get_files_with(path, contains_in_name, starts)
    folder_content = dir(path);
    file_array = struct2cell(folder_content);
    relevant_files = file_array(1,:);
    for i=1:length(contains_in_name)
        relevant_files = relevant_files(contains(relevant_files, contains_in_name{i}));
    end
    
    if ~isnan(starts)
        relevant_files = relevant_files(startsWith(relevant_files, starts));
    end
end