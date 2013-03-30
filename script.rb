
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'
require 'httParty'
require 'json'

JSC_URL = "https://www.jogossantacasa.pt/web/SCCartazResult/euroMilhoes"

FIRST_AVAILABLE = 7283

DATE 			= '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/span'
KEY 	 		= "//*[@id=\"frmContestSelection\"]/div/div[2]/div[3]/div/div/div[3]/ul/li[1]"
REVENUE  		= '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/div[8]/ul[1]/li[2]'
MONEY_AVAILABLE = '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/div[8]/ul[2]/li[2]'
TICKETS 		= '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/div[8]/ul[3]/li[2]'
COMBINATIONS	= '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/div[8]/ul[4]/li[2]'
BETS			= '//*[@id="frmContestSelection"]/div/div[2]/div[3]/div/div/div[8]/ul[5]/li[2]'


class RaffleInfo
	attr_accessor :date, :key, :prizes

	def initialize(date, key, prizes)
		@date   = date
		@key    = key
		@prizes = prizes
	end

	def to_json
		hash = {}
        self.instance_variables.each do |var|
            hash[var] = self.instance_variable_get var
        end
        hash.to_json
	end

	def to_s
		self.to_json.to_s
	end
end

def getAmountForPrize(page, index)
	path = "//*[@id=\"frmContestSelection\"]/div/div[2]/div[3]/div/div/div[5]/ul[#{index}]/li[5]"	
	page.xpath(path).to_s.sub(/&#8364;/, '').sub(/<li>/, '').sub(/<\/li>/, "").sub(/\?/, "").strip
end

def getRaffle(raffle)
	response = HTTParty.post(JSC_URL, :query => {:selectContest => raffle})
	page = Nokogiri::HTML(response.body)
	key 	= page.xpath(KEY).to_s.strip.sub(/<li>/, '').sub(/<\/li>/, "")
	date 	= page.xpath(DATE).to_s.strip.sub(/<span class="dataInfo">/, '').sub(/<\/span>/, "")

	prizes = []
	13.times do |t| 
		prizes << getAmountForPrize(page, t+1)
	end
	RaffleInfo.new(date, key, prizes)
end


last = 7504
all_raffles = []
(FIRST_AVAILABLE..last).each do |raffle|
	all_raffles << getRaffle(raffle)
end
p all_raffles


