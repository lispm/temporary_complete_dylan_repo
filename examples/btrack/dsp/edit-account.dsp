<%dsp:taglib name="btrack" prefix="bt" />

<html>
<head><title>Bug Tracker - Admin - Edit Account</title></head>

<body bgcolor="#FFFFFF">

<%dsp:include url="header.dsp"/>

<dsp:show-form-notes/>

<center><h1>Edit Account</h1></center>

<form name="editAccountForm" method="post" action="edit-account.dsp">
  <dsp:show-hidden-fields/>
  <table border="0">
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="95%" colspan="3">
        <span class="fieldTitle">Username:</span>
        <br><input name="name" type="text" size="30" maxlen="30"
                   value="<bt:show-name/>">
      </td>
    </tr>
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="95%" colspan="3">
        <span class="fieldTitle">Password:</span>
        <br><input name="password" type="password" size="30" maxlen="30"
                   value="<bt:show-password/>">
      </td>
    </tr>
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="95%" colspan="3">
        <span class="fieldTitle">E-mail address:</span>
        <br><input name="email_address" type="text" size="60" maxlen="100"
                   value="<bt:show-email-address/>">
      </td>
    </tr>
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="95%" colspan="3">
        <input name="Submit" type="Submit" value="Submit">
      </td>
    </tr>
  </table>

</form>

<%dsp:include url="footer.dsp"/>

</body>
</html>
