def log(err_message)
  unless f = File.open("log_#{Time.now.strftime("%Y%m")}.txt",'a')
    f = File.new("log_#{Time.now.strftime("%Y%m")}", 'a')
  end
  f.puts("#{err_message} #{Time.now.to_s}")
end

log("So we have create a Brand New File!")
