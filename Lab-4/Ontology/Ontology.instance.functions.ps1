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

        # Define array of result objects
        $instancelist = @()

        foreach ($instance in $xml.Ontology.Declaration.NamedIndividual.IRI.Trim('#'))
        {
            $instancelist += [pscustomobject]@{InstanceName = $instance}
        }

        # If there are class hierarchy
        if ($xml.Ontology.Declaration.Class)
        {
            # For each object in the result array
            foreach ($instance in $instancelist)
            {
                
            }
        }
        $instancelist
    }
    else
    {
        # Resolve path error
        Write-Output -InputObject $ea.Exception.Message
    }
}
