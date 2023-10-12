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

        foreach ($instance in $xml.Ontology.Declaration.NamedIndividual.IRI)
        {
            $instancelist += [pscustomobject]@{InstanceName = $instance.Trim('#')}
        }

        # If there are class hierarchy
        if ($xml.Ontology.Declaration.Class)
        {
            # For each object in the result array
            foreach ($instance in $instancelist)
            {
                # Create empty classnames array
                $classnames = @()
                # Find corresponding ClassAssertion nodes
                if ($nodes = $xml.Ontology.ClassAssertion |
                             Where-Object -Property NamedIndividual |
                             Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -eq "#$($instance.InstanceName)"})
                {
                    # For each corresponding ClassAssertion node
                    foreach ($node in $nodes)
                    {
                        # Add classname to array
                        $classnames += $node.Class.IRI.Trim('#')
                    }
                }
                # Add classnames array as Class property to object (empty array if the instance is not assigned to any class)
                $instance | Add-Member -MemberType NoteProperty -Name Class -Value $classnames
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
