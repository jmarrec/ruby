if have_library('kernel32', 'AddDllDirectory')
  create_makefile('win32/dll_directory')
end
