using System;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Sitecore.XConnect;
using Sitecore.XConnect.Client;
using Sitecore.XConnect.Collection.Model;

namespace ConsoleApp6
{
    public class Program
    {
        private static void Main()
        {
            Console.WriteLine("initializing client");
            var client = GetXConnectClient().Result;
            using (client)
            {
                RunDemo(client).GetAwaiter().GetResult();
                Console.WriteLine("press enter to exit");
                Console.ReadLine();
            }
        }

        private static async Task RunDemo(XConnectClient client)
        {
            var contactCountSolr = await client.Contacts.Where(x => x.Identifiers.Any(i => i.Source == "test")).Count();
            await AddContacts(client);
            Console.WriteLine("Total contacts in the system: " + await client.Contacts.Count());
            Console.WriteLine("Contacts returned by search:");
            var watch = Stopwatch.StartNew();
            var contacts = await client.Contacts.Where(c => c.LastModified > DateTime.UtcNow.AddMonths(-1)).GetBatchEnumerator(10000);
            var parallelContactSearches = await contacts.CreateSplits(2);
            var totalContactsReturned = 0;
            await Task.WhenAll(parallelContactSearches.Select(search =>
            {
                var contactsReturned = 0;
                return search.ForEachAsync(c =>
                {
                    if (++contactsReturned % 10000 == 0)
                        Console.Write("\r" + Interlocked.Add(ref totalContactsReturned, 10000));
                });
            }));
            watch.Stop();
            Console.WriteLine("");
            Console.WriteLine("Finished reading all contacts in " + watch.Elapsed);
        }

        private static async Task AddContacts(XConnectClient client)
        {
            for (int i = 0; i < 1000; i++)
            {
                Console.Write("\rAdding 1000 contacts, set number: {0}", i);
                for (int j = 0; j < 1000; j++)
                {
                    client.AddContact(new Contact(new ContactIdentifier("test", Guid.NewGuid().ToString(),
                        ContactIdentifierType.Known)));
                }

                await client.SubmitAsync();
            }

            Console.WriteLine("");
        }

        private static async Task<XConnectClient> GetXConnectClient()
        {
            var uri = new Uri("https://sc92demo.xconnect");
            var config = new XConnectClientConfiguration(CollectionModel.Model, uri);
            await config.InitializeAsync();
            return new XConnectClient(config);
        }
    }
}
