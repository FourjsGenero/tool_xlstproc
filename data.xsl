<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
  <body>
    <h2>List of contacts</h2>
    <table border="1">
      <tr>
        <th>Name</th>
		<th>Country</th>
        <th>Email</th>
      </tr>
      <xsl:for-each select="list/person">
      <tr>
        <td><xsl:value-of select="name" /></td>
		<td><xsl:value-of select="country" /></td>
        <td><xsl:value-of select="email" /></td>
      </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>