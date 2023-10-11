function Get-OwlInstance
{
    Param([string]$FileName)
    
    # Resolve path
    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    # If path exists
    if ($path)
    {
        # Create new object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        # Load XML file
        $xml.Load($path)

        $result = @()

        foreach ($instance in $xml.Ontology.Declaration.NamedIndividual.IRI.Trim('#'))
        {
            $result += [pscustomobject]@{InstanceName = $instance}
        }

        $result
    }
    else
    {
        # Resolve path error
        Write-Output -InputObject $ea.Exception.Message
    }
}
