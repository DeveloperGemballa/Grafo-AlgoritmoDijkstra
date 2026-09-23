program DijkstraAlgoritmo;  
  
{ 
  +---------------------------------------------+
	|PROIBIÇÕES DO BASTOS:                        |
	| - S/ Break e Exit;                          |
	| - S/ Variável Global Dentro de Rotinas      |
  +---------------------------------------------+
}  

	const
	  MAX_VERTICES = 24;
	  INFINITO     = 999999;
	
	type
	  TVetorNomes    = Array[1..MAX_VERTICES] of String;
	  TMatrizCusto   = Array[1..MAX_VERTICES, 1..MAX_VERTICES] of Integer;
	  TVetorDist     = Array[1..MAX_VERTICES] of Integer;
	  TVetorVisitado = Array[1..MAX_VERTICES] of Boolean;
	  TVetorAnterior = Array[1..MAX_VERTICES] of Integer; // Rastreia o caminho
	
	var
	  Nomes                          : TVetorNomes;
	  MatrizCusto                    : TMatrizCusto;
	  TotalVertices, i, j, OpcaoMenu : Integer;  
	  Inicio, Fim                    : String;

	// Inicializa o grafo vazio de acordo com o algoritmo do maluco
	procedure InicializarGrafo(var MatrizCusto : TMatrizCusto; var iTotalVertices : Integer);
		var
		  i, j: integer;
	begin
	  iTotalVertices := 0;
	  for i := 1 to MAX_VERTICES do
	    for j := 1 to MAX_VERTICES do
	      if i = j then
	        MatrizCusto[i, j] := 0
	      else
	        MatrizCusto[i, j] := INFINITO;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	// Incluir Vertice pra gente montar nosso grafo
	procedure IncluirVertice(nome : String; var GrafoNomes : TVetorNomes; var iTotalVertices : Integer);
	begin
	  if iTotalVertices < MAX_VERTICES then
	  begin
	    iTotalVertices := iTotalVertices + 1;
	    GrafoNomes[iTotalVertices] := nome;
	  end
	  else
	    writeln('Erro: Limite máximo de vertices atingido no grafo, favor verificar.');
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Funcao auxiliar para encontrar o indice numérico do vértice pelo nome para facilitar a vida
	function BuscarVertice(sNome : String; iTotalVertices : Integer; aNomes : TVetorNomes) : Integer;
		var
		  i      : Integer;
		  bAchou : Boolean;
	begin
	  BuscarVertice := 0;
	  bAchou        := False;
	  
	  for i := 1 to iTotalVertices do
	    if (aNomes[i] = sNome) and (not bAchou)then
	    begin
	      BuscarVertice := i;
	      bAchou := True;
	    end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Incluir Aresta pra montar as ligações malucas
	procedure IncluirAresta(nomeOrigem, nomeDestino : String; peso : Integer; var iTotalVertices : Integer; var aNomes : TVetorNomes; var aMatrizCusto : TMatrizCusto);
		var
		  idOrigem, idDestino : Integer;
	begin
	  idOrigem  := BuscarVertice(nomeOrigem, iTotalVertices, aNomes);
	  idDestino := BuscarVertice(nomeDestino, iTotalVertices, aNomes);
	
	  if (idOrigem > 0) and (idDestino > 0) then
	  begin
	    aMatrizCusto[idOrigem, idDestino] := peso;
	    aMatrizCusto[idDestino, idOrigem] := peso; // Grafo não direcionado, portanto é necessário repetir o mesmo valor na outra direção
	  end
	  else
	    writeln('Erro: Algum dos vértices informados não foram encontrados (', nomeOrigem, ' -> ', nomeDestino, ').');
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Buscar Menor Caminho (essa deu trabalho puta que pariu)
	procedure BuscarMenorCaminho(nomeOrigem, nomeDestino : String; var iTotalVertices : Integer; var aNomes : TVetorNomes; var aMatrizCusto : TMatrizCusto);
		var
		  Dist                                  : TVetorDist;
		  Visitado                              : TVetorVisitado;
		  Anterior                              : TVetorAnterior; 
		  idOrigem, idDestino, i, v, u, minDist : Integer;
		  CaminhoInverso                        : Array[1..MAX_VERTICES] of Integer;
		  TamanhoCaminho                        : Integer;
		  bEncerrar                             : Boolean;
	begin                           
	  idOrigem  := BuscarVertice(nomeOrigem, iTotalVertices, aNomes);
	  idDestino := BuscarVertice(nomeDestino, iTotalVertices, aNomes);
	
	  if (idOrigem = 0) or (idDestino = 0) then
	  begin
	  	TextColor(Red);
	    writeln('Erro: Vértice de origem ou destino nao encontrado.');	    
	  end
	  else
	  begin	
		  // Config inicial
		  for i := 1 to iTotalVertices do
		  begin
		    Dist[i] := INFINITO;
		    Visitado[i] := false;
		    Anterior[i] := 0; // 0 = significa que ainda nao tem anterior
		  end;
		  Dist[idOrigem] := 0;
		
			bEncerrar := False;
		  // Dijkstra
		  for i := 1 to iTotalVertices do
		  begin
		  	if not bEncerrar then
		  	begin
			    minDist := INFINITO;
			    u := 0;
			
			    // Encontra o vértice não visitado com a menor distância atual
			    for v := 1 to iTotalVertices do
			    begin
			      if (not Visitado[v]) and (Dist[v] <= minDist) then
			      begin
			        minDist := Dist[v];
			        u := v;
			      end;
			    end;
			
			    // Se não há mais vértices pra ir ele interrompe
			    if (u = 0) or (minDist = INFINITO) then 
						bEncerrar := True;
						
			    if not bEncerrar then
			    begin
				    Visitado[u] := true;
				
				    // Se chegou no fim ja pode parar de procurar
				    if u = idDestino then 
							bEncerrar := True;
				
						if not bEncerrar then
						begin
					    // Atualiza as distâncias dos vizinhos de u
					    for v := 1 to iTotalVertices do
					    begin
					      if (not Visitado[v]) and (aMatrizCusto[u, v] <> INFINITO) and (Dist[u] <> INFINITO) then
					      begin
					        // Se encontrou um caminho mais curto
					        if Dist[u] + aMatrizCusto[u, v] < Dist[v] then
					        begin
					          Dist[v] := Dist[u] + aMatrizCusto[u, v];
					          Anterior[v] := u; // Guarda que pra chegar em "v", passou por "u"
					        end;
					      end;
					    end;	    
				    end;
			    end;	    
		  	end;
		  end;
	  end;
	
	  // Caminho
	  writeln;
	  writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
	  TextColor(White);
	  write('Menor Caminho Calculado de "');  
	  TextColor(LightBlue);
		write(nomeOrigem);  
	  TextColor(White);
		write('" para "'); 
	  TextColor(LightBlue);
		write(nomeDestino);  
	  TextColor(White);
		writeln('"');
	  
	  if Dist[idDestino] = INFINITO then
	  begin
	  	TextColor(Red);
	    writeln('Nao existe caminho possível entre os vertices.');
	  end
	  else
	  begin         
	  	TextColor(White);
	    write(' > Custo Total (Distância): ');    
	  	TextColor(LightBlue);
			writeln(Dist[idDestino]);
	    
	    TamanhoCaminho := 0;
	    u := idDestino;
	    
	    while u <> 0 do
	    begin
	      TamanhoCaminho := TamanhoCaminho + 1;
	      CaminhoInverso[TamanhoCaminho] := u;
	      u := Anterior[u]; // Pega quem veio antes dele
	    end;
	
	    // Como o vetor foi preenchido do destino pra origem fica o contraio    
	  	TextColor(White);
	    write(' > Rota Calculada.........: ');
	    for i := TamanhoCaminho downto 1 do
	    begin
	    	TextColor(LightBlue);
	      write(Nomes[CaminhoInverso[i]]);    
	    	TextColor(DarkGray);
	      if i > 1 then 
					write(' -> ');
	    end;
	    writeln;
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		

	procedure MostrarMatrizCusto(aMatrizCusto : TMatrizCusto; aVertices : TVetorNomes);
		var
			i, j : Integer;
	begin                 		
	  TextColor(LightGreen);   
	  writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
		writeln('                               __  ____  __  . ____ '+#13#10+
						'                         |\/| |__|  |   |  \ |    / ');
		writeln('                         |  | |  |  |   |__/ |   /  '+#13#10+
						'                         |  | |  |  |   |  \ |  /__ '+#13#10);  

	  TextColor(Green);  						
	  write('     ');
	  for i:= 1 to MAX_VERTICES do
	  	Write('  ',aVertices[i],'   ');
	  writeln;                          
	  writeln('----------------------------------------------------------------------------------------------------------------------------------------------------');
	  
	  for i:= 1 to MAX_VERTICES do
	  begin
	    TextColor(Green);
	    Write(' ',aVertices[i],' | ');
			for j:= 1 to MAX_VERTICES do
				if (aMatrizCusto[i,j] <> INFINITO) and (aMatrizCusto[i,j] <> 0) then
				begin
					TextColor(White);
					write(aMatrizCusto[i,j]:5:0, ' ');
				end
				else
				begin
					textcolor(DarkGray); 
					write('  *   ');
				end;
				
			writeln;
		end;   
	  TextColor(LightGreen);   
	  writeln(#13#10+'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
	end;   
	                
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	procedure CarregaVertices(var GrafoNomes : TVetorNomes; var TotalDeVertices : Integer);
	begin  
		// Testando IncluirVertice | A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X |
		IncluirVertice('A', GrafoNomes, TotalDeVertices);    
		IncluirVertice('B', GrafoNomes, TotalDeVertices);
		IncluirVertice('C', GrafoNomes, TotalDeVertices);
		IncluirVertice('D', GrafoNomes, TotalDeVertices);
		IncluirVertice('E', GrafoNomes, TotalDeVertices);    
		IncluirVertice('F', GrafoNomes, TotalDeVertices);
		IncluirVertice('G', GrafoNomes, TotalDeVertices);
		IncluirVertice('H', GrafoNomes, TotalDeVertices);
		IncluirVertice('I', GrafoNomes, TotalDeVertices);
		IncluirVertice('J', GrafoNomes, TotalDeVertices);
		IncluirVertice('K', GrafoNomes, TotalDeVertices);
		IncluirVertice('L', GrafoNomes, TotalDeVertices);
		IncluirVertice('M', GrafoNomes, TotalDeVertices);
		IncluirVertice('N', GrafoNomes, TotalDeVertices);
		IncluirVertice('O', GrafoNomes, TotalDeVertices);
		IncluirVertice('P', GrafoNomes, TotalDeVertices);
		IncluirVertice('Q', GrafoNomes, TotalDeVertices);
		IncluirVertice('R', GrafoNomes, TotalDeVertices);
		IncluirVertice('S', GrafoNomes, TotalDeVertices);
		IncluirVertice('T', GrafoNomes, TotalDeVertices);
		IncluirVertice('U', GrafoNomes, TotalDeVertices);
		IncluirVertice('V', GrafoNomes, TotalDeVertices);
		IncluirVertice('W', GrafoNomes, TotalDeVertices);  
		IncluirVertice('X', GrafoNomes, TotalDeVertices);	
	end;     
	                
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	procedure CarregaArestas(var GrafoNomes : TVetorNomes; var TotalDeVertices : Integer; var aMatrizCustos : TMatrizCusto);
	begin 
		// A
		IncluirAresta('A', 'B', 40,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'C', 40,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'D', 120, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'E', 120, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'L', 50,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'O', 50,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'Q', 150, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'S', 50,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'U', 50,  TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('A', 'W', 150, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// B
		IncluirAresta('B', 'D', 80, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// C
		IncluirAresta('C', 'E', 80, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// D
		IncluirAresta('D', 'F', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('D', 'J', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('D', 'L', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('D', 'N', 15, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// E
		IncluirAresta('E', 'G', 15, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('E', 'I', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('E', 'M', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('E', 'O', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// F
		IncluirAresta('F', 'H', 40, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('F', 'L', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('F', 'N', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('F', 'V', 200, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// G
		IncluirAresta('G', 'I', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// H
		IncluirAresta('H', 'J', 50, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// I
		IncluirAresta('I', 'K', 40, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('I', 'O', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('I', 'V', 200, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// J
		IncluirAresta('J', 'L', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('J', 'O', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('J', 'V', 50, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// K
		IncluirAresta('K', 'M', 50, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// L
		IncluirAresta('L', 'M', 30, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('L', 'O', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// M
		IncluirAresta('M', 'O', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('M', 'V', 50, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// N
		IncluirAresta('N', 'P', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('N', 'X', 5, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// P
		IncluirAresta('P', 'R', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// Q
		IncluirAresta('Q', 'S', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('Q', 'U', 70, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// R
		IncluirAresta('R', 'T', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// S
		IncluirAresta('S', 'U', 20, TotalDeVertices, GrafoNomes, aMatrizCustos);
		IncluirAresta('S', 'W', 70, TotalDeVertices, GrafoNomes, aMatrizCustos);                                                                                            
		//-------------------------------//
		// T
		IncluirAresta('T', 'X', 10, TotalDeVertices, GrafoNomes, aMatrizCustos);
		//-------------------------------//
		// U
		IncluirAresta('U', 'W', 20, TotalDeVertices, GrafoNomes, aMatrizCustos); 
	end;

{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	

begin
  InicializarGrafo(MatrizCusto, TotalVertices);
	CarregaVertices(Nomes, TotalVertices);
	CarregaArestas(Nomes, TotalVertices, MatrizCusto);
	  
  OpcaoMenu := -1;
	while OpcaoMenu <> 0 do
	begin  	
		TextColor(LightGreen);
		writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
		WriteLn('      ___           '+#13#10+
						'|\/| |    |\  | |  |'+#13#10+
						'|  | |-   | \ | |  |'+#13#10+
						'|  | |___ |  \| \__/'+#13#10);	
		WriteLn(' - 1 - Calcular distância entre os vértices informados'+#13#10+
		        ' - 2 - Visualizar a matriz de custo gerada do algoritmo'+#13#10+#13#10+
		        ' - 0 - Finalizar Execução'+#13#10);
		
		Write('> Informe a opção do menu: ');
		ReadLn(OpcaoMenu);
		WriteLn('------------------');
		
		case OpcaoMenu of
		  1 : begin
				    // Testando o BuscarMenorCaminho
				    Write(' > |INICIO| Informe o vertice de inicio da busca: ');  
				    ReadLn(Inicio);                
				    Write(' > |  FIM | Informe o vertice de fim da busca...: ');  
				    ReadLn(Fim);                                         
				    BuscarMenorCaminho(Inicio, Fim, TotalVertices, Nomes, MatrizCusto);
		      end;
		  2 : MostrarMatrizCusto(MatrizCusto, Nomes);
		  0 : Writeln;
		  else
		  	TextColor(Red);
		  	Writeln('Informe uma opção válida para o menu!');
		end;
	end;
	
end.