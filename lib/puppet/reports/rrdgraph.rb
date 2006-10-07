require 'puppet'

Puppet::Server::Report.newreport(:rrdgraph) do
    desc "Graph some data about hosts."

    def process
        time = Time.now.to_i

        host = self.host

        hostdir = File.join(Puppet[:rrddir], host)

        unless File.directory?(hostdir)
            # Some hackishness to create the dir
            config = Puppet::Config.new
            config.setdefaults(:reports, :hostdir => [hostdir, "eh"])

            # This creates the dir.
            config.use(:reports)
        end

        File.open(File.join(hostdir, "index.html"),"w") { |of|
            of.puts "<html><body>"
            self.metrics.each do |name, metric|
                metric.basedir = hostdir
                metric.store(time)

                metric.graph

                of.puts "<img src=%s.png><br>" % name
            end

            of.puts "</body></html>"
        }
    end
end

# $Id$
