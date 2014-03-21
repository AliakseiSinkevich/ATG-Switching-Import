repository_mapping = {}
repository_mapping['ContentRepository'] = '/com/nbty/repository/ContentRepository'
repository_mapping['PriceLists'] = '/atg/commerce/pricing/priceLists/PriceLists'
repository_mapping['SiteRepository'] = '/atg/multisite/SiteRepository'
repository_mapping['ProductCatalog'] = '/atg/commerce/catalog/ProductCatalog'

DATA_IMPORT_DIR = 'C:/ATG/ATG10.1.1/NBTY/env-install/data'
CONSOLE_COMMAND_MAX_LENGTH = 2000


def start_sql_repository(repository, import)
  puts "Import for repository: #{repository}"
  puts "Import argument: #{import}"
  puts %x( call %DYNAMO_HOME%/bin/startSQLRepository -s cat_a_script_server -m NBTY.Commerce -repository #{repository} #{import} )
end

def get_imported_files(repository_name)
  imported_files = []
  begin
    File.foreach("logs/#{repository_name}_imported.txt") do |line|
      imported_files.push(line.chomp)
    end
  rescue Errno::ENOENT
# ignored
  end
  imported_files
end

def save_list_of_imported_files(imported_files, repository_name)
  File.open("logs/#{repository_name}_imported.txt", 'a') do |f|
    f.puts(imported_files)
  end
end

def perform_import(repository_name, repository_component)
  files_to_import = Dir["#{DATA_IMPORT_DIR}/#{repository_name}/*.xml"]
  files_to_import -= get_imported_files(repository_name)

  if files_to_import.empty?
    puts "Nothing to import for repository #{repository_name}."
  else
    %x( cd #{DATA_IMPORT_DIR}/#{repository_name}/ )
    import = ''
    files_to_import.each do |file|

      if import.length + " -import #{file}".length > CONSOLE_COMMAND_MAX_LENGTH
        start_sql_repository(repository_component, import)
        import = ''
      end
      import += " -import #{file}"
    end

    start_sql_repository(repository_component, import)

    save_list_of_imported_files(files_to_import, repository_name)
    puts 'Done.'
  end
end


repository_mapping.each_pair { |repo_name, repo_component| perform_import(repo_name, repo_component) }



