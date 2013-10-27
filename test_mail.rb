require 'pony'
def ping(ip, time)
  result = `ping -c 1 #{ip.chomp}`
  p result
  pars = /time=([0-9]+\.[0-9]+) ms/
  exit_st = $?.exitstatus
  if time == '+'
    if exit_st==0
      pars = /time=([0-9]+\.[0-9]+) ms/
      @ping_time = result.scan(pars).flatten!.first.to_f
    else
      @ping_time = nil
    end
  end
  exit_st
end

def mail(address, message)
  Pony.mail(:to => address.chomp, :via => :smtp,  :via_options => {
            :address     => 'smtp.gmail.com',
            :port     => '587',
            :enable_starttls_auto => :true,
            :user_name     => 'testinghumster@gmail.com',
            :password => 'qwerty1121',
            :authentication     => :plain,
            :domain   => "broadband-5-228-182-45.nationalcablenetworks.ru"
       },
            :subject => 'Yeah!',
            :body => message)
end

def log(err_message)
  unless f = File.open("log_#{Time.now.strftime("%Y%m")}.txt",'a')
    f = File.new("log_#{Time.now.strftime("%Y%m")}", 'a')
  end
  f.puts("#{err_message} #{Time.now.to_s}")
end




mails = IO.read('mails.txt').split
bad_message = IO.read('bad_message.txt')
good_message = IO.read('good_message.txt')
slow_message = IO.read('slow_message.txt')
after_dead_message = <<AFTERDEAD

Кто-то умер.

AFTERDEAD

printf "ip: "
ip = ""
ip = gets
printf "host: "
host = ""
host = gets

i=0
i_for_slow = 0.0
j=0

butthurt = false
need_to_mail = false
logged = false

@ping_time = 0

while true

  @ping = ping(ip, '+')
  @host = ping(host, '-')
  print "#{@ping}, #{@host}\n"
  puts @ping_time
  if @ping!=0 || @ping_time>200
    if @ping != 0
      i+=1
      if @host!=0
        if !logged
          log("Taskom is dead... #{Time.now}")
          after_dead_message += "\n#{Time.now}"
          logged = true
          shutdown= Time.now
          need_to_mail = true
          butthurt = true
        end
      else
        if i>=2 && !butthurt
          mails.each {|email_address| mail(email_address, bad_message)}
          butthurt = true
        end
        #i+=1
        log("Package lost. #{Time.now}")
      end

    else
      i_for_slow+=1
      if i_for_slow>=10
        butthurt = true
        mails.each {|email_address| mail(email_address, slow_message)}
      end
      log("Too slow package. #{Time.now}")
    end

  end
  j+=1


  if j == 4
  if i == 0 && i_for_slow = 0 && butthurt
      log("Chanel up. #{Time.now}")
      butthurt = false
      if need_to_mail
        after_dead_message += "\n#{Time.now}"
        wakeup = Time.now
        mails.each {|email_address| mail(email_address, after_dead_message)}
        need_to_mail = false
      end
      mails.each {|email_address| mail(email_address, good_message)}
    end
    i = 0
    j = 0
    i_for_slow = 0
  end


  puts "cicle"
  puts i
  puts j
  puts i_for_slow
  puts
  sleep 1
end
