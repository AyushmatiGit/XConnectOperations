<%@ Page Language="c#" Inherits="System.Web.UI.Page" CodePage="65001" Debug="true" Async="true" %>

<%@ OutputCache Location="None" VaryByParam="none" %>
<%@ Import Namespace="Sitecore.XConnect" %>
<%@ Import Namespace="Sitecore.XConnect.Client" %>
<%@ Import Namespace="Sitecore.XConnect.Client.Configuration" %>
<%@ Import Namespace="Sitecore.XConnect.Collection.Model" %>
<%@ Import Namespace="Sitecore.Analytics" %>

<!DOCTYPE html>
<style>
    h2 {
        background: #000080; /* Цвет фона блока */
        color: #ffe; /* Цвет текста */
        margin: 0; /* Нулевые отступы вокруг текста */
        padding: 10px; /* Поля вокруг текста */
    }

    h3 {
        background: #008000; /* Цвет фона блока */
        color: #ffe; /* Цвет текста */
        margin: 0; /* Нулевые отступы вокруг текста */
        padding: 10px; /* Поля вокруг текста */
    }

    h4 {
        background: #808080; /* Цвет фона блока */
        color: #ffe; /* Цвет текста */
        margin: 0; /* Нулевые отступы вокруг текста */
        padding: 10px; /* Поля вокруг текста */
    }

    h5 {
        background: #ff0000; /* Цвет фона блока */
        color: #ffe; /* Цвет текста */
        margin: 0; /* Нулевые отступы вокруг текста */
        padding: 10px; /* Поля вокруг текста */
    }

    h6 {
        background: #008000; /* Цвет фона блока */
        color: #ffe; /* Цвет текста */
        margin: 0; /* Нулевые отступы вокруг текста */
        padding: 3px; /* Поля вокруг текста */
    }

    table {
        column-count: 2;
        width: 100%;
    }

    td {
        vertical-align: top;
        width: 50%;
    }
</style>

<script runat="server">
    private XConnectClient client = SitecoreXConnectClientConfiguration.GetClient();

    public Contact KnownContact
    {
        get { return (Contact)Session["contact"]; }
        private set { Session["contact"] = value; }
    }

    public Interaction KnownInteraction
    {
        get { return (Interaction)Session["interaction"]; }
        private set { Session["interaction"] = value; }
    }

    public DeviceProfile deviceProfile
    {
        get { return (DeviceProfile)Session["DeviceProfile"]; }
        private set { Session["DeviceProfile"] = value; }
    }

    public IpInfo IpInfoFacet
    {
        get { return (IpInfo)Session["ipInfo"]; }
        private set { Session["ipInfo"] = value; }
    }


    public UserAgentInfo UserAgentInfoFacet
    {
        get { return (UserAgentInfo)Session["userAgentInfo"]; }
        private set { Session["userAgentInfo"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        contactPhoneLabel.Text = "Submitted phone number: " + contactPhoneCountryCode.Text + contactPhoneNumber.Text + contactPhoneExtension.Text;
        contactEmailLabel.Text = "Submitted email: " + contactEmailEmail.Text;
        contactAddressLabel.Text = "Submitted contact address: " + contactAddressCountry.Text + ", " +
                                   contactAddressCity.Text + ", " +
                                   contactAddressPostalCode.Text + ", " +
                                   contactAddressStateProvince.Text + ", " +
                                   contactAddressStreetLine1.Text + ", " +
                                   contactAddressLongitude.Text + ", " +
                                   contactAddressLatitude.Text;
        contactPersonaLabel.Text = "Submitted contact personal info: " + contactPersonalTitle.Text + ", " +
                                   contactPersonalFirstName.Text + ", " +
                                   contactPersonalMiddleName.Text + ", " +
                                   contactPersonalSurname.Text + ", " +
                                   contactPersonalSuffix.Text + ", " +
                                   contactPersonalGender.Text + ", " +
                                   contactPersonalJobTitle.Text;
    }

    protected async void TryLoadContact_Click(object sender, EventArgs e)
    {
        if (contactId.Text == "")
        {
            contactIdLabel.Text = "Such ID is not valid/correct.";
        }
        else
        {
            KnownContact = await client.GetContactAsync(new Guid(contactId.Text), new ExpandOptions(PersonalInformation.DefaultFacetKey, PhoneNumberList.DefaultFacetKey, EmailAddressList.DefaultFacetKey, AddressList.DefaultFacetKey));
            if (KnownContact == null)
            {
                contactIdLabel.Text = string.Empty;
                contactDetailLabel.Text = "Contact does not exist in xConnect anymore.";
                tblContactData.Visible = false;

            }
            else
            {
                contactIdLabel.Text = KnownContact.Id.ToString();
                contactDetailLabel.Text = "Contact exists in xConnect.";
                tblContactData.Visible = true;
                PopulateContactData(KnownContact);
            }

        }
    }

    private void PopulateContactData(Contact contact)
    {
        var phonenumbers = KnownContact.GetFacet<PhoneNumberList>();
        if (phonenumbers != null)
        {
            lblPhoneEntry.Text = phonenumbers.PreferredKey;
            lblPhoneCountryCode.Text = phonenumbers.PreferredPhoneNumber.CountryCode;
            lblPhoneExtension.Text = phonenumbers.PreferredPhoneNumber.Extension;
            lblPhoneNumber.Text = phonenumbers.PreferredPhoneNumber.Number;
        }

        var Pii = KnownContact.GetFacet<PersonalInformation>();
        if (Pii != null)
        {
            lblPITitle.Text = Pii.Title;
            lblPIFirstName.Text = Pii.FirstName;
            lblPIMiddleName.Text = Pii.MiddleName;
            lblPISurname.Text = Pii.LastName;
            lblPISuffix.Text = Pii.Suffix;
            lblPIGender.Text = Pii.Gender;
            lblPIJobtitle.Text = Pii.JobTitle;
        }

        var email = KnownContact.GetFacet<EmailAddressList>();
        if (email != null)
        {
            lblEmailEntry.Text = email.PreferredKey;
            lblEmail.Text = email.PreferredEmail.SmtpAddress;
        }

        var address = KnownContact.GetFacet<AddressList>();
        if (address != null)
        {
            lblAddressEntry.Text = address.PreferredKey;
            lblAddressCountry.Text = address.PreferredAddress.CountryCode;
            lblAddressCity.Text = address.PreferredAddress.City;
            lblAddressPostalCode.Text = address.PreferredAddress.PostalCode;
            lblAddressStateProvince.Text = address.PreferredAddress.StateOrProvince;
            lblAddressStreetLine1.Text = address.PreferredAddress.AddressLine1;
        }

    }

    protected async void AddIContactPhoneNumber_Click(object sender, EventArgs e)
    {
        if (contactPhoneEntrie.Text == "" ||
            contactPhoneNumber.Text == "" ||
            contactPhoneCountryCode.Text == "" ||
            contactPhoneExtension.Text == "")
        {
            contactPhoneLabel.Text = "Such number is not valid/correct.";
        }
        else
        {
            if (contactIdLabel.Text == "")
            {
                contactPhoneLabel.Text = "Could not load contact";
            }
            else
            {
                KnownContact = await client.GetContactAsync(new Guid(contactIdLabel.Text), new ExpandOptions(PhoneNumberList.DefaultFacetKey));
                var preferredPhoneNumber = new PhoneNumber(contactPhoneCountryCode.Text, contactPhoneNumber.Text)
                {
                    Extension = contactPhoneExtension.Text
                };
                var phonenumbers = KnownContact.GetFacet<PhoneNumberList>();
                if (phonenumbers == null)
                {
                    var phoneNumberFacet = new PhoneNumberList(preferredPhoneNumber, contactPhoneEntrie.Text);
                    phoneNumberFacet.PreferredKey = "Work";
                    client.SetPhoneNumbers(KnownContact, phoneNumberFacet);
                }
                else
                {
                    phonenumbers.Others.Add(contactPhoneEntrie.Text, preferredPhoneNumber);
                    client.SetPhoneNumbers(KnownContact, phonenumbers);
                }
                client.Submit();
            }
        }
    }

    protected async void AddIContactEmailAddresses_Click(object sender, EventArgs e)
    {
        if (contactEmailEntrie.Text == "" || contactEmailEmail.Text == "")
        {
            contactEmailLabel.Text = "Such email is not valid/correct.";
        }
        else
        {
            if (contactIdLabel.Text == "")
            {
                contactPhoneLabel.Text = "Could not load contact";
            }
            else
            {
                KnownContact = await client.GetContactAsync(new Guid(contactIdLabel.Text), new ExpandOptions(EmailAddressList.DefaultFacetKey));
                var emails = KnownContact.GetFacet<EmailAddressList>();
                var preferredEmailAddress = new EmailAddress(contactEmailEmail.Text, true);
                if (emails == null)
                {
                    var emailsFacet = new EmailAddressList(preferredEmailAddress, contactPhoneEntrie.Text)
                    {
                        PreferredKey = "Work"
                    };

                    client.SetEmails(KnownContact, emailsFacet);
                }
                else
                {
                    emails.Others.Add(contactPhoneEntrie.Text, preferredEmailAddress);
                    client.SetEmails(KnownContact, emails);
                }
                client.Submit();
            }
        }
    }

    protected async void AddIContactAddresses_Click(object sender, EventArgs e)
    {
        if (contactAddressEntrie.Text == "" ||
            contactAddressCountry.Text == "" ||
            contactAddressCity.Text == "" ||
            contactAddressPostalCode.Text == "" ||
            contactAddressStateProvince.Text == "" ||
            contactAddressStreetLine1.Text == "" ||
            contactAddressLongitude.Text == "" ||
            contactAddressLatitude.Text == "")
        {
            contactAddressLabel.Text = "Fill address fields";
        }
        else
        {
            if (contactIdLabel.Text == "")
            {
                contactPhoneLabel.Text = "Could not load contact";
            }
            else
            {
                KnownContact = await client.GetContactAsync(new Guid(contactIdLabel.Text), new ExpandOptions(AddressList.DefaultFacetKey));
                var preferredAddress = new Address()
                {
                    City = contactAddressCity.Text,
                    CountryCode = contactAddressCountry.Text,
                    PostalCode = contactAddressPostalCode.Text,
                    StateOrProvince = contactAddressStateProvince.Text,
                    AddressLine1 = contactAddressStreetLine1.Text,
                    GeoCoordinate = new GeoCoordinate(double.Parse(contactAddressLatitude.Text), double.Parse(contactAddressLongitude.Text))
                };

                var address = KnownContact.GetFacet<AddressList>();
                if (address == null)
                {
                    var addressesFacet = new AddressList(preferredAddress, contactAddressEntrie.Text);
                    client.SetAddresses(KnownContact, addressesFacet);
                }
                else
                {
                    address.Others.Add(contactAddressEntrie.Text, preferredAddress);
                    client.SetAddresses(KnownContact, address);
                }
                client.Submit();
            }
        }
    }

    protected async void AddIContactPersonalInfo_Click(object sender, EventArgs e)
    {
        if (contactIdLabel.Text == "")
        {
            contactPhoneLabel.Text = "Could not load contact";
        }
        else
        {
            KnownContact = await client.GetContactAsync(new Guid(contactIdLabel.Text), new ExpandOptions(PersonalInformation.DefaultFacetKey));
            var personalInfoFacet = new PersonalInformation()
            {
                Title = contactPersonalTitle.Text,
                FirstName = contactPersonalFirstName.Text,
                MiddleName = contactPersonalMiddleName.Text,
                LastName = contactPersonalSurname.Text,
                Suffix = contactPersonalSuffix.Text,
                Gender = contactPersonalGender.Text,
                JobTitle = contactPersonalJobTitle.Text
            };

            client.SetPersonal(KnownContact, personalInfoFacet);
            client.Submit();
        }
    }

    protected async void RTBF_Click(object sender, EventArgs e)
    {

        if (contactIdRTF.Text == "")
        {
            ContactError.Text = "<h5>Such ID is not valid/correct.</h5>";
        }
        else
        {
            KnownContact = await client.GetContactAsync(new Guid(contactIdRTF.Text), new ExpandOptions());
            if (KnownContact != null)
            {
                client.ExecuteRightToBeForgotten(KnownContact);
                client.Submit();
            }
            else
            {
                ContactError.Text = "<h5>Contact was not identified</h5>";
            }
        }
    }

    protected async void Delete_Click(object sender, EventArgs e)
    {

        if (contactIdRTF.Text == "")
        {
            ContactError.Text = "<h5>Such ID is not valid/correct.</h5>";
        }
        else
        {
            KnownContact = await client.GetContactAsync(new Guid(contactIdRTF.Text), new ExpandOptions());
            if (KnownContact != null)
            {
                client.DeleteContact(KnownContact);
                client.SubmitAsync();
            }
            else
            {
                ContactError.Text = "<h5>Contact was not identified</h5>";
            }
        }
    }

    private void Contact_Click(object sender, EventArgs e)
    {
        var contact = new Contact();
        client.AddContact(contact);
        client.SubmitAsync().ConfigureAwait(false).GetAwaiter().GetResult();
        KnownContact = contact;
        contactIdLabel.Text = KnownContact.Id.ToString();
    }

</script>

<html lang="en">
<head>
    <title>Working with Contact</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="CODE_LANGUAGE" content="C#" />
    <meta name="vs_defaultClientScript" content="JavaScript" />
    <meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5" />
    <link href="/default.css" rel="stylesheet" />
</head>
<body style="margin-left: 10px">
    <form method="post" runat="server" id="mainform">
        <div id="MainPanel">
            <h2>Working with Contact</h2>
            <br>
            <p>
                <h3>Load contact</h3>
                <br>
                Contact ID:
                <asp:TextBox ID="contactId" runat="server" />
                <asp:Button ID="LoadContact" runat="server" Text="Submit" OnClick="TryLoadContact_Click" />
                <asp:Label ID="contactIdLabel" runat="server" />
                <asp:Label ID="contactDetailLabel" runat="server" />
            <p>
                <table id="tblContactData" runat="server">
                    <tr>
                        <td>
                            <h3>Contact Data</h3>
                            <h4>Personal Info</h4>
                            <br>
                            Title:
                            <asp:Label ID="lblPITitle" runat="server" /><br>
                            FirstName:
                            <asp:Label ID="lblPIFirstName" runat="server" /><br>
                            MiddleName:
                            <asp:Label ID="lblPIMiddleName" runat="server" /><br>
                            Surname:
                            <asp:Label ID="lblPISurname" runat="server" /><br>
                            Suffix:
                            <asp:Label ID="lblPISuffix" runat="server" /><br>
                            Gender:
                            <asp:Label ID="lblPIGender" runat="server" /><br>
                            JobTitle:
                            <asp:Label ID="lblPIJobtitle" runat="server" /><br>
                        </td>
                    </tr>
                    <tr>
                        <td>

                            <h4>Phone Number</h4>
                            Entry:
                            <asp:Label ID="lblPhoneEntry" runat="server" /><br>
                            CountryCode:
                            <asp:Label ID="lblPhoneCountryCode" runat="server" /><br>
                            Number:
                            <asp:Label ID="lblPhoneNumber" runat="server" /><br>
                            Extension:
                            <asp:Label ID="lblPhoneExtension" runat="server" /><br>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h4>Email Addresses</h4>
                            <br>
                            Entry:
                            <asp:Label ID="lblEmailEntry" runat="server" /><br>
                            Email:
                            <asp:Label ID="lblEmail" runat="server" Text="" /><br>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h4>Addresses</h4>
                            <br>
                            Entry:
                            <asp:Label ID="lblAddressEntry" runat="server" /><br>
                            Country:
                            <asp:Label ID="lblAddressCountry" runat="server" /><br>
                            City:
                            <asp:Label ID="lblAddressCity" runat="server" /><br>
                            PostalCode:
                            <asp:Label ID="lblAddressPostalCode" runat="server" /><br>
                            StateProvince:
                            <asp:Label ID="lblAddressStateProvince" runat="server" /><br>
                            StreetLine1:
                            <asp:Label ID="lblAddressStreetLine1" runat="server" /><br>
                        </td>
                    </tr>

                </table>
            </p>
            <p>
                <h3>Delete Contact</h3>
                <br />
                Contact ID:
                <asp:TextBox ID="contactIdRTF" runat="server" Style="width: 300px" />
                <asp:Button ID="Delete" runat="server" Text="Delete Contact!" OnClick="Delete_Click" />
                <asp:Label ID="ContactError" runat="server" />
                <br>
                <p>
                    <asp:Label ID="contactIdentifier" runat="server" />
            <p>
                <table>
                    <tr>
                        <td>
                            <h3>Add contact data</h3>
                            <h4>IContactPhoneNumber</h4>
                            Entrie:
                            <asp:TextBox ID="contactPhoneEntrie" runat="server" /><br>
                            CountryCode:
                            <asp:TextBox ID="contactPhoneCountryCode" runat="server" /><br>
                            Number:
                            <asp:TextBox ID="contactPhoneNumber" runat="server" /><br>
                            Extension:
                            <asp:TextBox ID="contactPhoneExtension" runat="server" /><br>
                            <asp:Button ID="AddPhoneNum" runat="server" Text="Submit Phone Number" OnClick="AddIContactPhoneNumber_Click" />
                            <asp:Label ID="contactPhoneLabel" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h4>IContactEmailAddresses</h4>
                            <br>
                            Entrie:
                            <asp:TextBox ID="contactEmailEntrie" runat="server" /><br>
                            Email:
                            <asp:TextBox ID="contactEmailEmail" runat="server" Text="" /><br>
                            <asp:Button ID="AddEmail" runat="server" Text="Submit Email" OnClick="AddIContactEmailAddresses_Click" />
                            <asp:Label ID="contactEmailLabel" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h4>IContactAddresses</h4>
                            <br>
                            Entrie:
                            <asp:TextBox ID="contactAddressEntrie" runat="server" /><br>
                            Country:
                            <asp:TextBox ID="contactAddressCountry" runat="server" /><br>
                            City:
                            <asp:TextBox ID="contactAddressCity" runat="server" /><br>
                            PostalCode:
                            <asp:TextBox ID="contactAddressPostalCode" runat="server" /><br>
                            StateProvince:
                            <asp:TextBox ID="contactAddressStateProvince" runat="server" /><br>
                            StreetLine1:
                            <asp:TextBox ID="contactAddressStreetLine1" runat="server" /><br>
                            Location.Longitude:
                            <asp:TextBox ID="contactAddressLongitude" runat="server" /><br>
                            Location.Latitude:
                            <asp:TextBox ID="contactAddressLatitude" runat="server" /><br>
                            <asp:Button ID="AddAddress" runat="server" Text="Submit Address" OnClick="AddIContactAddresses_Click" />
                            <asp:Label ID="contactAddressLabel" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h4>IContactPersonalInfo</h4>
                            <br>
                            Title:
                            <asp:TextBox ID="contactPersonalTitle" runat="server" /><br>
                            FirstName:
                            <asp:TextBox ID="contactPersonalFirstName" runat="server" /><br>
                            MiddleName:
                            <asp:TextBox ID="contactPersonalMiddleName" runat="server" /><br>
                            Surname:
                            <asp:TextBox ID="contactPersonalSurname" runat="server" /><br>
                            Suffix:
                            <asp:TextBox ID="contactPersonalSuffix" runat="server" /><br>
                            Gender:
                            <asp:TextBox ID="contactPersonalGender" runat="server" /><br>
                            JobTitle:
                            <asp:TextBox ID="contactPersonalJobTitle" runat="server" /><br>
                            <asp:Button ID="AddPersonalInfo" runat="server" Text="Submit Personal Info" OnClick="AddIContactPersonalInfo_Click" />
                            <asp:Label ID="contactPersonaLabel" runat="server" />
                        </td>
                    </tr>
                </table>
        </div>
    </form>
</body>
</html>
