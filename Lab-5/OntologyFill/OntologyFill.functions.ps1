function Import-OwlOntology
{
    Param(
        [string]$FileName,
        [string]$Url = "https://www.simplilearn.com/best-programming-languages-start-learning-today-article"
    )

    $ClassName = "Language"

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Create new object
            $xml = New-Object -TypeName System.Xml.XmlDocument
            # Load XML file
            $xml.Load($path)

            # Get page content
            $response = Invoke-WebRequest -Uri $Url

            # Define pattern
            $pattern = '(?s)<article><h2 id="\d+.*?</article>'
            # If there are pattern matches
            if ($ms = Select-String -InputObject $response.Content -Pattern $pattern -AllMatches)
            {
                # Get articles
                $articles = $ms.Matches.Value

                $patterntable = '(?s)<h2 id.*?>\d+\. (?<Name>.+)</h2>.*?(?<Table><table>.*?</table>)'
                $patternul = '(?s)<h2 id.*?>\d+\. (?<Name>.+?)\s?</h2>.*?(?<Benefits><h3>Benefits.*?</ul>).*?(?<Cons><h3>Con.*?</ul>)'

                foreach ($article in $articles)
                {
                    if ($ms = Select-String -InputObject $article -Pattern $patterntable)
                    {
                        $InstanceName = $ms.Matches.Groups[1].Value -replace '\s', '_' -replace '#','S'
                        Write-Output -InputObject "Adding: $InstanceName"
                        inAddInstance -xml $xml -InstanceName $InstanceName -ClassName $ClassName
                    }
                    elseif ($ms = Select-String -InputObject $article -Pattern $patternul)
                    {
                        $InstanceName = $ms.Matches.Groups[1].Value -replace '\s', '_' -replace '#','S'
                        Write-Output -InputObject "Adding: $InstanceName"
                        inAddInstance -xml $xml -InstanceName $InstanceName -ClassName $ClassName
                    }
                }

                # Save file
                $xml.Save("C:\t.xml")
            }
            else
            {
                Write-Output -InputObject "Web page does not contain requested data"
            }
        }
        else
        {
            # Resolve path error
            Write-Output -InputObject $ea.Exception.Message
        }
    }
    else
    {
        # FileName is not specified
        Write-Output -InputObject "File name is not specified"
    }
}


function inAddInstance
{
    Param (
        [System.Xml.XmlDocument]$xml,
        [string]$InstanceName,
        [string]$ClassName
    )

    # If instance exists
    if ("#$InstanceName" -cin $xml.Ontology.Declaration.NamedIndividual.IRI)
    {
        Write-Output -InputObject "The instance is already exists"
    }
    else
    {
        # If ClassName is specified and there are no such a class
        if ($ClassName)
        {
            if ("#$ClassName" -cnotin $xml.Ontology.Declaration.Class.IRI)
            {
                Write-Output -InputObject "There are no such a class: $ClassName"
                return
            }
        }

        # Create Declaration node with default namespace URI
        $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Declaration", $xml.DocumentElement.NamespaceURI)

        # Create NamedIndividual node with default namespace URI
        $namedindividual = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)

        # Set NamedIndividual node attribute
        $namedindividual.SetAttribute("IRI", "#$InstanceName")

        # Append NamedIndividual node as a child to Declaration node
        $declaration.AppendChild($namedindividual) | Out-Null

        # Append Declaration node as a child to Ontology node
        $xml.Ontology.AppendChild($declaration) | Out-Null

        if ($ClassName)
        {
            # Create ClassAssertion node
            $classassertion = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "ClassAssertion", $xml.DocumentElement.NamespaceURI)
            # Create Class node
            $classnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
            # Set Class node attribute
            $classnode.SetAttribute("IRI", "#$ClassName")
            # Create NamedIndividual node
            $namedindividualnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)
            # Set NamedIndividual node attribute
            $namedindividualnode.SetAttribute("IRI", "#$InstanceName")
            # Append Class node as a child to ClassAssertion node
            $classassertion.AppendChild($classnode) | Out-Null
            # Append NamedIndividual node as a child to ClassAssertion node
            $classassertion.AppendChild($namedindividualnode) | Out-Null
            # Append ClassAssertion node as a child to Ontology node
            $xml.Ontology.AppendChild($classassertion) | Out-Null
        }
    }
}
