require 'watir'

def main

  # from origin url: https://americanliterature.com/author/w-w-jacobs/short-story/the-monkeys-paw
  lines = File.readlines('monkeys_paw.txt').map(&:chomp)

  chromedriver_path = File.join([File.absolute_path('../../../../../../'), 'opt', 'chromedriver', 'chromedriver'])
  Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path

  bser = Watir::Browser.new
  bser.goto 'http://nlp.stanford.edu:8080/ner/'

  out = ''
  classifiers = ['english.muc.7class.distsim.crf.ser.gz', 'english.conll.4class.distsim.crf.ser.gz', 'english.all.3class.distsim.crf.ser.gz', 'chinese.misc.distsim.crf.ser.gz']
  classifiers.each do |classifier|
    outs = []
    lines.each_slice(10) do |t|
      bser.textarea(name: 'input').value = t.join(' ')
      bser.select(name: 'classifier').select(text: classifier)
      bser.select(name: 'outputFormat').select(text: 'inlineXML')
      bser.input(name: 'Process').click
      bser.wait_until do
        bser.url == 'http://nlp.stanford.edu:8080/ner/process'
      end
      sleep(2)
      body_text = bser.body.outer_html
      bser.body.children.each do |c|
        body_text = body_text.gsub(c.outer_html, '')
      end
      outs << body_text
      File.open(classifier + '.html', 'w').write('<html><body>' + outs.join("<br/><br/>\n\n") + '</body></html>')
    end
  end
end

main
