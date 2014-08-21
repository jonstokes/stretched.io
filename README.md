stretched.io
============

[Stretched.io](http://stretched.io) is a platform-as-a-service that lets you scrape web pages
using only YAML/JSON, xpath queries, and regular expressions. There's
also a ruby DSL that can be used as-is or easily extended for those who prefer to scrape with ruby.

In the example below, we'll see how easy it is to scrape a news site
with some code like the following:

```yaml
object_adapter:
  www.arstechnica.com/article_link:
    xpath: //li[@class='post']
    scripts:
      - www.arstechnica.com/article_link
    attribute:
      title:
        - find_by_xpath:
            xpath: .//a/h1[@class='heading']/span[@class='whole']
        - find_by_xpath:
            xpath: .//article[@class='in-column']/h1[@class='heading']/a
      excerpt:
        - find_by_xpath:
            xpath: .//p[@class='excerpt']
      author:
        - find_by_xpath:
            xpath: .//p[@class='byline']
            pattern: /by\s*.*/i
          filters:
            - reject: /by\s*/
      story_type:
        - label_by_xpath:
            label: on_the_radar
            xpath: .//article[@class='in-column']
        - value: in_depth
```

To [scrape a site with stretched](https://github.com/jonstokes/stretched.io/wiki/Overview:-How-it-Works), you perform the following simple steps:

1. Register a `schema` that describes the kind of object that you want to
   extract from a site's pages.
2. Register an `object_adapter` that tells stretched how to extract the
   objects from a page using xpath and regular expressions.
3. Register a `session_definition` and some `rate_limits` that tell
   stretched how to interact with the website and what kinds of pages to
expect (i.e. xml, html, or AJAX).
4. Create crawl `sessions` containing some urls and push them into a `session_queue`
5. Pop the `object_queue` to get your nicely formatted and validated JSON objects.

Steps 1 through 3 are setup steps that only need to be done once. You
can then repeat steps 4 and 5 as many times as you like in order to
crawl a site.

![A logical view of stretched.io](http://jonstokes.com/wp-content/uploads/2014/08/stretched.png)

The current incarnation of stretched.io is running in
production as an internal PaaS for a stealth-mode project that scrapes between 200 and 250 retail sites. 
The internal API that we use for creating
registrations, populating session queues, and popping object queues, talks directly to redis.
 If we decide to open this up as a platform, the public REST API will resemble that of ElasticSearch.
So for all of the YAML that you see below, imagine posting it via
`curl`.

Before we jump into an example, let's try to answer a few questions
that you might have about this project.

# Questions and Answers

## Who is this for, and what's the point?
Ruby doesn't really have a complete web scraping toolkit that compares
to Python's scrapy, but it does have a bunch of tools that work really
well: Nokogiri, Capybara, and Poltergeist, for instance. But putting all
of these ingredients together to crawl and scrape the web can be a huge pain, 
and it's also really hard to farm this kind of work out cheaply to subcontractors when you need to do it on a massive scale.
That's where stretched comes in.

Stretched isn't for one-off scraping jobs or pet projects, although you
can use it for that. Rather, stretched shines when you need to do a *lot* of
high-touch scraping that involves writing xpath queries,
and you need to do it cheaply using contract
labor that may not know how to use git, or ruby, or python, or your tech
stack of choice.

For the large web scraping project that we've built on the stretched.io
platform, we've been able to use [odesk](http://odesk.com/) to hire foreign contractors to
build object adapters for the project. The process is extremely easy, because the contractors don't need to be able to write or
debug ruby code -- *all they need to know is xpath and regex to be fully
productive with the system*. Even if they don't know YAML, they can learn
it in a few minutes.

As for debugging, we just lint the YAML, and we run it through some
validators to ensure that the platform can understand it. These
validators can also be trivially programmed to give useful,
instantaneous feedback that catches almost every error someone is likely
to make in writing an adapter. This means that a contractor
in India can easily and safely submit code into a web form, and get
instant feedback on whether it's syntactically correct or not.

There's also a nice [ruby DSL](https://github.com/jonstokes/stretched.io/wiki/Registrations:-Scripts) that's there if we need it, and it maps exactly to the [YAML
interface](https://github.com/jonstokes/stretched.io/wiki/Registrations:-Object-Adapter-YAML-Reference). 
And we have an [extensions feature](https://github.com/jonstokes/stretched.io/wiki/Registrations:-Extensions) that lets us define
methods that every script can call (sort of like a ruby module).
So there's a ton of flexibility here that can be called on to handle
special cases.

The main answer to the question of who stretched.io is for, is "us". We
use it internally to scrape the web, and the contractors that have worked with it really
love it. So we thought, why not see if anyone else would be interested
in using it?

## If this is real, where's the live demo?
We're currently using this in production on a stealth mode project, and we don't have the time or
the resources to allocate to producing a live demo right now. But it is
real, and it does work, and it does scale.

## I thought you said JSON, so what's with all the YAML?
YAML is a superset of JSON, so if you don't speak YAML, just use
JSON instead. Both will work. We like YAML and we use it internally.

## Why a PaaS, and not an open source ruby gem?
There are a few reasons why we're considering offering this as a PaaS,
but not as an open-source product. 

First, scraping-as-a-service on EC2
is awesome. End users don't have to worry about maintaining hundreds of
parallel phantomjs instances, or getting blocked by CloudFlare as a
botnet, and so on. If you've ever tried to do a significant amount of
scraping from a small home or office machine, then you probably get the
appeal of just doing this in the cloud and letting someone else deal
with the dirty details.

Second, this platform represents part of our stealth-mode startup's "secret sauce" -- it's fast,
flexible, scalable, and very easy to use. It's been painstakingly
developed over the course of the past 2 years in the trenches of web scraping, and it provides us with a critical
competitive advantage in what we're trying to do. As much as we love
FOSS, we have no plans to give this away.

We may, however, open up some parts of it, if the PaaS idea gains
traction and there's some interest.

## Why shouldn't I just use Kimono?
Kimono is crushing it, and if you're using Kimono and are happy with it then
you should definitely keep using it, and please don't hit our [sign-up page](http://signup.stretched.io) and
indicate your interest in stretched. If the
outcome of our exploration into turning stretched into a user-facing
PaaS is that everyone's needs are met by Kimono, then that's a perfectly
acceptable outcome, because then we can avoid spending time one a
service that nobody will sign up for.

That said, here are a few key differences between the two platforms:

If you want to scrape a few sites, Kimono is awesome. But if you want to 
scrape a few hundred sites on an indefinite basis, and farm out the work of 
creating and maintaining adapters for those sites to a distributed team of contractors, 
then stretched may work better, depending on whether Kimono's
collaboration tools will be a good fit for your team when they launch.

Kimono is a SaaS product with all of the
UX bells and whistles that that implies. Stretched is a PaaS, so it's a
at a different layer of the stack. We're not focused on building a
point-and-click UX, and we have no plans to. Our UX is YAML/JSON + regexp +
xpath (plus a dash of ruby if you need it), and our distributed team
interacts with it entirely through text and code.

This deliberate decision to keep everything text-based, and to let
clients use their own collaboration tools, is based on the fact that there's a large universe
of fantastic tools available for distributed teams to collaborate on
building and maintaining a shared pool of text objects -- version
control systems, collaborative editors, environments like Slack and
Hipchat, and even old-fashioned email. We prefer to piggyback on all of
that, and not reinvent the collaboration wheel. So stretched plugs right
into that development ecosystem.

For our internal project we keep all of the YAML
that describes the retail sites we scrape in a github repo, so we get all of the benefits of
fine-grained access and version control as we try to keep the adapters current and add new ones.
This is trivially easy to do with stretched. Some trusted contractors
get access to that main repo of adapter code, while others submit code via a web form (after using an
in-house QA tool to test it and confirm that it scrapes as
expected). At any rate, the point is that we don't have to build any
collaboration tools into the platform -- you just use your own to create
JSON in whatever way you like, and submit that JSON to stretched. The
user experience strives to emulate that of a hosted ElasticSearch service -- JSON in, JSON out -- hence
the name "stretched".

Another difference is that stretched's DSL offers the ability to do scripted sessions, which we
use in our own project. For instance, some retail sites won't show you a price until
you've clicked on a quantity, so we can use the `Capybara::Session`
object to interact with the page in these situations.

Finally, we dogfood stretched, and have done so for a long time now. We do a ton of crawling, and stretched
has to work for us. Even if we open up stretched to the rest of the
world as a PaaS, we still plan to keep working on our original product
scraping platform.

## Where can I learn more?
The wiki has a version of the documentation that we use internally to bring contractors up to speed on the
platform, so you can check that out for more details.

## Where can I sign up and start using this?
You can't, yet. Right now, we're trying to figure out if it's worth our
time to wrap a REST API around this and build a real user-facing service 
around it, with user accounts, subscriptions, etc. If you like what you
see here and you think you'd pay for it, then hit our [pre-launch sign-up
page](http://signup.stretched.io) and send us your email. We'll be in touch if there's enough
interest.

# Example

Lets' say that I wanted to scrape the front page of Ars Technica for
news articles, and create an array of JSON objects like the following out of the articles on the
page:

```yaml
{
  {
    title: 'Seals carried tuberculosis across the Atlantic, gave it to humans',
    excerpt: 'Disease was present in the Americas prior to European contact.',
    author: 'JOHN TIMMER',
    url: 'http://arstechnica.com/science/2014/08/seals-carried-tuberculosis-across-the-atlantic-gave-it-to-humans/',
    story_type: 'in_depth'
  },
  {
    title: 'FCC Republican wants to let states block municipal broadband',
    excerpt: 'Democrats warned not to take action a future Republican-led FCC would dislike.',
    author: 'JON BRODKIN',
    url: 'http://arstechnica.com/business/2014/08/fcc-republican-wants-to-let-states-block-municipal-broadband/',
    story_type: 'in_depth'
  },
  {
    title: 'How Twitter’s new "BotMaker" filter flushes spam out of timelines',
    excerpt: 'Sifting spam from ham at scale and in real time is a hard problem to solve.',
    author: 'LEE HUTCHINSON',
    url: 'http://arstechnica.com/information-technology/2014/08/how-twitters-new-botmaker-filter-flushes-spam-out-of-timelines/',
    story_type: 'on_the_radar'
  },
  # ...
}
```

## Schema and Object Adapter

First, I'll register a `schema` with stretched.io that describes the objects
that I want to extract from the Ars homepage:

```yaml
schema:
  article_link:
    title: Article Link
    description: A link to an article
    properties:
      title:   { type: string }
      excerpt: { type: string }
      author:  { type: string }
      url:     { type: url }
      story_type:
        type: string
        enum: ['in_depth', 'on_the_radar']
    required: [ 'title', 'excerpt', 'url' ]
```

(The schema above partially conforms to the JSON Schema spec, but notice
that the `url` type is non-standard. See the wiki for more info.)

Next, I can tell stretched how to read the Ars page and create objects that fit the
schema above by registering an `object_adapter` with the
platform:

```yaml
object_adapter:
  www.arstechnica.com/article_link:
    xpath: //li[@class='post'],
    scripts:
      - www.arstechnica.com/article_link
    attribute:
      title:
        - find_by_xpath:
            xpath: .//a/h1[@class='heading']/span[@class='whole']
        - find_by_xpath:
            xpath: .//article[@class='in-column']/h1[@class='heading']/a
      excerpt:
        - find_by_xpath:
            xpath: .//p[@class='excerpt']
      author:
        - find_by_xpath:
            xpath: .//p[@class='byline']
            pattern: /by\s*.*/i
          filters:
            - reject: /by\s*/
      story_type:
        - label_by_xpath:
            label: on_the_radar
            xpath: .//article[@class='in-column']
        - value: in_depth
```

I'll also register the following ruby script with the platform. I could
do this with YAML/JSON in the adapter above, but I include the script
for illustration purposes:

```ruby
Stretched::Script.define do
  script 'www.arstechnica.com/article_link' do
    url { find_by_xpath(xpath: './/a/@href' ) }

    author do |instance|
      instance.author.upcase if instance.author?
    end
  end
end
```

The object adapter above is relatively straightforward. The `key` is the
adapter's unique name within the system, and it can be any string. The `xpath` gives us the nodes
that contain all of the objects that we're interested in extracting. For
each node at the `xpath`, the adapter tries to turn that node into an `article_link` object using the
`attribute` hash and, if necessary, the `scripts` manifest.

We can't go over every detail of the adapter above -- that's best left
for the wiki (see [here](https://github.com/jonstokes/stretched.io/wiki/Registrations:-Object-Adapter) 
and [here](https://github.com/jonstokes/stretched.io/wiki/Registrations:-Object-Adapter-YAML-Reference)) -- but it is worthwhile to point out a few aspects of how
the object_adapter sets some of the attributes.

**title**: You can see that here are two attribute setters here, in an
array. The adapter looks for a match at the first setter, and if it
finds one it returns it; otherwise, it moves on to the second setter,
and so on.

**author**: I've included a `filters` manifest here, just to show the
capability. The xpath given for this attribute returns something like
the following:

```
  by     John Timmer
  -    Aug 21, 7:00am CDT
```

The `pattern` argument to `find_by_xpath` captures only the text "by
John Timmer", and if there were no `filters` it would just return that
string. However, I've told it to take the output of the `find_by_xpath`
method and `reject` the pattern `/by\s*/`, so that the entire setter
returns simply "John Timmer". The filters are applied progressively 
to transform output of `find_by_xpath`, and other filter types are `accept`, `prefix`, and
`postfix`.

**story_type**: The `label_by_xpath` method returns the value of `label`
if it finds anything at all at the `xpath` that matches its `pattern`
argument. The `value` method returns whatever argument you give it (in
this case the text "in_depth"), and is used for setting default
fall-through values. In other words, if the first setter method comes up
empty-handed, the adapter will work its way down to the `value` method
and just return that.

The scripts are run after the `attribute` hash in whatever order they're
listed. The script above uses a ruby DSL to set the `url` attribute, and
to transform the output of the `attribute` hash's `author` stanza into
uppercase. (The `instance` variable is a `Hashie::Mash` that's populated
with the output of the YAML adapter, and which the user can mutate
however he/she likes over the course of the script. The script also
gives the user access to a `Hasie::Mash` of the page's
code/headers/body/etc., a `Nokogiri::Document` of the page, and a
`Capybara::Session` object powered by [poltergeist](https://github.com/teampoltergeist/poltergeist).) 

Now that we've registered an `object_adapter` for
extracting news links and a `schema` for validating them,
we're almost ready to scrape the page.

## Sessions

Stretched carries out its scrapes by popping a `session_queue` that the user registers and populates, so let's
register one real quick:

```yaml
session_queue:
  www.arstechnica.com: {}
```

Let's also register a `session_definition` and a `rate_limit` that tell
stretched how to interact with the website and its pages:

```yaml
rate_limit:
  global/standard_rate_limits:
    timezone: America/Chicago
    off_peak:
      start: '23:00'
      duration: 7 # hours
      rate: 4 # seconds/page 
    peak:
      start: '06:01'
      duration: 17 # hours
      rate: 8 # seconds/page
```

```yaml
session_definition:
  global/standard_html_session:
    page_format: html
    rate_limits: global/standard_rate_limits
```

The `rate_limit` registration above tells the platform to scrape at a rate of one
page every 4 seconds during the off-peak time block, and one page every 8
seconds during peak hours. 

The `session_definition` registration tells stretched to use the rate limits
that we just defined. Its `page_format` value tells
stretched to process the pages with `Nokogiri::HTML.parse()`. Note that
if the `page_format` were set to `dhtml`, stretched would also capture the
pages with phantomjs, which would execute JavaScript and would give any
scripts access to a `Capybara::Session` object for dynamic interaction
with the page.

Now we're ready to push the following `session` to the `session_queue`
that we registered above:

```yaml
queue: www.arstechnica.com
session_definition: global/standard_html_session
object_adapters:
  - www.arstechnica.com/article_link
urls:
  - url: http://arstechnica.com/
```

This will load up the Ars front page, extract all of the articles as
JSON objects (labelled as coming from the "In Depth" or "On the Radar"
columns), and push all of those JSON objects into a queue called
`article_link`. 

If you popped the `article_link` queue, you'd see something like the
following:


```json
{
  "page": {
    "url": "http://arstechnica.com/",
    "code": 200,
    "headers": {
      "server": ["nginx"],
      "date": ["Thu, 21 Aug 2014 16:53:53 GMT"],
      "content-type": ["text/html; charset=UTF-8"],
      "transfer-encoding": ["chunked"],
      "connection": ["keep-alive"],
      "x-ars-server": ["web10"]
    },
    "response_time": 628,
    "fetched": true,
  },
  "session": {
    "key": "5fd62abffe58dbe6d6b32700",
    "queue_name": "www.arstechnica.com",
    "definition_key": "www.arstechnica.com/article_link",
    "started_at": "2014-08-21 11:55:22",
    
  },
  "object": {
    "title": "Seals carried tuberculosis across the Atlantic, gave it to humans",
    "excerpt": "Disease was present in the Americas prior to European contact.",
    "author": "JOHN TIMMER",
    "url": "http://arstechnica.com/science/2014/08/seals-carried-tuberculosis-across-the-atlantic-gave-it-to-humans/",
    "story_type": "in_depth"
  }
}
```

If you popped the `article_link` queue a few more times, you'd see the
same `page` and `session` hashes, but a different `object` hash each
time.

# A few more questions and answers

## Where to next?
If you're curious and want to poke around, there's much more info on how
it all works in the [wiki](https://github.com/jonstokes/stretched.io/wiki). Note that the wiki is definitely a work-in-progress, and it doesn't describe all of the features of the platform yet.

As for the idea of stretched.io as an actual service that people can
sign up for, that's up to you. We use stretched every day and love it.
If you'd like to use it, too, then head over to our
[sign-up page](http://signup.stretched.io) and
submit your email address. Once we have a sense of the interest level,
we'll know if we should devote resources to opening it up or not.

If you want to talk about stretched.io or have any questions, you can
reach me via email: it's my first name at the domain of [my personal website](http://jonstokes.com/).

## How can I spider a site with this?
You register a schema/adapter pair that captures the links that you want
to crawl and puts them into an object queue, and then you pop that
object queue and feed its output back into the session queue. It's up to
you to keep track of the links that you've seen so that you don't keep
re-crawling the same links over and over again, but that's not hard to
do.

## How can I tell when a site's redesign has broken my adapters?
There's no built-in facility for this, but here's how we handle this on
our own project, where we scrape retail sites for product listings. 
We add a `valid` property to our main object schema,
and then we set that attribute with some code like the following:

```ruby
Stretched::Script.define do
  script 'globals/validation' do
    valid do |instance|
      (instance.price? || instance.sale_price?) && instance.image && instance.availability && instance.title
    end
  end
end
```

We use the above bit of code to
confirm that a page at a particular URL is a valid listing -- not
"valid" in the "does this validate with the JSON schema?", but valid in
the "does this actually describe a real product listing, in that it has
all of the attributes that a listing should have?". When a redesign
breaks our adapter and those attributes start returning nil, then the
output of our object queue starts producting objects where `valid:
false`, and we know we have a problem.

The general principle here is this: find some attribute or combination
of attributes that, when they start showing up as nil, will tip
you off that the adapter is now broken, and keep an eye on your output.

