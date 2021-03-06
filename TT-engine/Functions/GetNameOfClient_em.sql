DROP FUNCTION IF EXISTS `GetNameOfClient_em`;
DELIMITER $$

CREATE DEFINER=`vmoroz`@`%` FUNCTION `GetNameOfClient_em`(`tab_on` INT(2) UNSIGNED, `inv_num_kli` INT(11) UNSIGNED ) RETURNS varchar(500) CHARSET cp1251
    READS SQL DATA
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
      IF tab_on=0 THEN
      begin 
        DECLARE adr VARCHAR(250);
        DECLARE kli VARCHAR(250);
        SELECT `adress`,`klient` INTO adr, kli FROM zaporozhie WHERE `inv_number`=inv_num_kli;  
        RETURN concat_ws(' - ', adr, kli);
      end;
      END IF;
      IF tab_on=1 THEN
      begin
        DECLARE Bdate VARCHAR(250);
        DECLARE Kli VARCHAR(250);
        DECLARE NameB VARCHAR(250);
        SELECT `beg_date`,`klient`,`name_bid` INTO Bdate, Kli, NameB FROM reglament WHERE `reg_id`=inv_num_kli;
        RETURN concat_ws(' - ', Bdate, Kli, NameB);
      end;
      END IF;
      IF tab_on=2 THEN
      begin
        DECLARE Eq VARCHAR(250);
        DECLARE Kli VARCHAR(250);
        SELECT c.equip, k.client INTO Eq, Kli FROM collocation c, tab_klients k WHERE c.id_col=inv_num_kli AND k.id=c.kli_id;
        RETURN concat_ws(' - ', Kli, Eq);
      end;
      END IF;
      IF tab_on=3 THEN
      begin
        DECLARE N TINYINT;
        DECLARE Node VARCHAR(250);
        DECLARE Adr VARCHAR(250);
        DECLARE Twn VARCHAR(150);
        SELECT count(*), i.node_old, i.address, t.town INTO N, Node, Adr, Twn FROM tblinform2 i, tab_town t WHERE i.inv_id=inv_num_kli AND t.id=i.town_id;
        if N=0 THEN RETURN 'ERROR';
        else RETURN concat('���.�������� - ',Node,' - ',Twn,', ',Adr);
        end if;
      end;
      END IF;
      IF tab_on=4 THEN
      begin 
        DECLARE N TINYINT;
        DECLARE NMS VARCHAR(250);
        DECLARE Node VARCHAR(250);
        DECLARE L TINYINT;
        SELECT count(*), `name_nms`,`num_node`,`linkage` INTO N, NMS, Node, L FROM net_equip WHERE `id_equip`=inv_num_kli AND `num_node`<>0;
        if N=0 THEN RETURN 'ERROR';
        else
        begin
          if L=0 then 
          begin
            DECLARE Adr VARCHAR(250);
            DECLARE Twn VARCHAR(150);
            SELECT `town`,`address` INTO Twn, Adr FROM tblinform2 t, tab_town w, tab_country c, tab_area a WHERE t.town_id=w.id AND w.country_id=c.id AND w.area_id=a.id AND t.inv_id=Node;
            RETURN concat(NMS,' - ',Twn,', ',Adr);
          end;
          else
          begin
            DECLARE Kli VARCHAR(250);
            DECLARE St VARCHAR(250);
            DECLARE Twn VARCHAR(150);
            SELECT `client`,`town`,`street` INTO Kli, Twn, St FROM office_kli o, tab_klients k, tab_town t, tab_country c, tab_area a WHERE o.klient=k.id AND o.town_id=t.id AND t.country_id=c.id AND t.area_id=a.id AND o.id_kli=Node;
            RETURN concat(NMS,' - ',Kli,', ',Twn,', ',St);
          end;
          end if;
        end;
        end if;
      end;
      END IF;
      IF tab_on=5 THEN
      begin
        DECLARE N TINYINT;
        DECLARE e_a VARCHAR(250);
        DECLARE e_b VARCHAR(250);
        DECLARE Fl TINYINT;
        DECLARE p_a VARCHAR(50);
        DECLARE p_b VARCHAR(50);
        DECLARE Ps VARCHAR(50);
        SELECT count(*), `equip_a`,`equip_b`,`flag_link`,`port_a`,`port_b`,`pass` INTO N, e_a, e_b, Fl, p_a, p_b, Ps FROM net_links WHERE `id_link`=inv_num_kli;
        if N=0 THEN RETURN 'ERROR';
        else
        begin
          DECLARE NMS VARCHAR(250);
          SELECT `name_nms` INTO NMS FROM net_equip WHERE `id_equip`=e_a;
          if Fl=1 then
          begin
            DECLARE Kli VARCHAR(250);
            SELECT `client` INTO Kli FROM tab_klients WHERE `id`=e_b;
            RETURN concat('�� - ',NMS,' ',p_a,' -- ',p_b,' ',Kli,' ��������: ',Ps,' ����/�');
          end;
          else
          begin
            DECLARE NMS2 VARCHAR(250);
            SELECT `name_nms` INTO NMS2 FROM net_equip WHERE `id_equip`=e_b;
            RETURN concat('�� - ',NMS,' ',p_a,' -- ',p_b,' ',NMS2,' ��������: ',Ps,' ����/�');
          end;
          end if;
        end;
        end if;
      end;
      END IF;
      IF tab_on=6 THEN
      begin
        DECLARE N TINYINT;
        DECLARE Kli VARCHAR(250);
        DECLARE Twn VARCHAR(150);
        DECLARE Twn_ua VARCHAR(150);
        DECLARE St VARCHAR(250);
        DECLARE St_ua VARCHAR(250);
        DECLARE Em_profil VARCHAR(50);
        DECLARE translit VARCHAR(500);
        SELECT count(*), k.`client`,t.`town`,t.`town_ua`, o.`street`, o.`street_ua`,k.emailtemplate INTO N,Kli,Twn,Twn_ua,St,St_ua,Em_profil FROM office_kli o, tab_klients k, tab_town t WHERE k.`id`=o.`klient` AND t.`id`=o.`town_id` AND  `id_kli`=inv_num_kli;
        if N=0 THEN RETURN 'ERROR';
        else  IF Em_profil = 'BASE_EN' THEN BEGIN
                                            RETURN concat(Kli,', ',Twn_ua,', ',St_ua);
                                            END;
              ELSE RETURN concat(Kli,', ',Twn,', ',St);
              END IF;
        end if;
      end;
      END IF;
      IF tab_on=7 THEN
      
      begin
        DECLARE N TINYINT;
        DECLARE of_a INT(5) unsigned;
        DECLARE of_b INT(5) unsigned;
        DECLARE Sp VARCHAR(50);
        DECLARE Kl VARCHAR(250);
        DECLARE sk_type VARCHAR(150);
        DECLARE sk_type_en VARCHAR(150);
        DECLARE Em_profil VARCHAR(50);
        DECLARE translit VARCHAR(500);
        DECLARE skid INT(3);
        SELECT count(*), d.`office_a`,d.`office_b`,d.`speed`,k.`client`,sk.`name_bs`,sk.`name_en`,k.emailtemplate, sk.id  INTO N, of_a, of_b, Sp, Kl, sk_type,sk_type_en, Em_profil, skid FROM net_data d, tab_klients k, tab_katal_sk_type sk WHERE d.`client`=k.`id` AND d.`type_serv_d`=sk.`id` AND `id_data`=inv_num_kli;
        if N=0 THEN RETURN 'ERROR';
        else

        begin
          DECLARE Twn VARCHAR(150);
          DECLARE Twn_ua VARCHAR(150);
          DECLARE St VARCHAR(250);
          DECLARE St_ua VARCHAR(250);
          DECLARE Twn2 VARCHAR(150);
          DECLARE Twn2_ua VARCHAR(150);
          DECLARE St2 VARCHAR(250); 
          DECLARE St2_ua VARCHAR(250); 
          SELECT `town`,`town_ua`,`street`,`street_ua` INTO Twn,Twn_ua, St,St_ua FROM office_kli o, tab_town t WHERE t.id=o.town_id AND o.`id_kli`=of_a;
          SELECT `town`,`town_ua`,`street`,`street_ua` INTO Twn2,Twn2_ua, St2,St2_ua FROM office_kli o, tab_town t WHERE t.id=o.town_id AND o.`id_kli`=of_b;
          
          if (skid = '2' OR skid = '3') THEN 
              BEGIN
                      DECLARE nSp VARCHAR(50);
                      if Sp=NULL then SET nSp='?';
                      else SET nSp=Sp;
                      end if;
                          IF Em_profil = 'BASE_EN' THEN BEGIN
                                                        RETURN concat(Kl,', ',sk_type_en,', ',nSp,' Mbit/s, (',Twn2_ua,', ',St2_ua,')');
                                                        END;
                          ELSE RETURN concat(Kl,', ',sk_type,', ',nSp,' ����/�, (',Twn2,', ',St2,')');
                          END IF;
              END;
          else begin
                if Twn=Twn2 then
                    begin
                        DECLARE nSp VARCHAR(50);
                        if Sp=NULL then SET nSp='?';
                        else SET nSp=Sp;
                        end if;
                          IF Em_profil = 'BASE_EN' THEN BEGIN
                                                        RETURN concat(Kl,', ',sk_type_en,', ',nSp,' Mbit/s (',Twn_ua,', ',St_ua,' - ',St2_ua,')');
                                                        END;
                          ELSE RETURN concat(Kl,', ',sk_type,', ',nSp,' M���/�, (',Twn,', ',St,' - ',St2,')');
                          END IF;
                    end;
                else
                    begin
                      DECLARE nSp VARCHAR(50);
                      if Sp=NULL then SET nSp='?';
                      else SET nSp=Sp;
                      end if;
                          IF Em_profil = 'BASE_EN' THEN BEGIN
                                                        RETURN concat(Kl,', ',sk_type_en,', ',nSp,' Mbit/s, (',Twn_ua,', ',St_ua,' - ',Twn2_ua,', ',St2_ua,')');
                                                        END;
                          ELSE RETURN concat(Kl,', ',sk_type,', ',nSp,' ����/�, (',Twn,', ',St,' - ',Twn2,', ',St2,')');
                          END IF;
                    end;
                end if;
              END;
            END IF;
        end;
        end if;
      
      end;
      
      END IF;
      IF tab_on=8 THEN
      begin   
        DECLARE N TINYINT;
        DECLARE oper INT(5) unsigned;
        DECLARE s_a VARCHAR(250);
        DECLARE t_a INT(5) unsigned;
        DECLARE s_b VARCHAR(250);
        DECLARE t_b INT(5) unsigned;
        SELECT count(*),`operator`,`side_a`,`town_a`,`side_b`,`town_b` INTO N, oper, s_a, t_a, s_b, t_b  FROM net_operators WHERE `id_oper`=inv_num_kli;
        if N=0 THEN RETURN 'ERROR';
        else
        begin
          DECLARE Kli VARCHAR(250);
          DECLARE Twn VARCHAR(250);
          DECLARE Twn2 VARCHAR(250);
          SELECT `client`  INTO Kli FROM tab_klients WHERE `id`=oper;
          SELECT `town` INTO Twn FROM tab_town WHERE `id`=t_a;
          SELECT `town` INTO Twn2 FROM tab_town WHERE `id`=t_b;
          RETURN concat('��� - ',Kli,', ',Twn,', ',s_a,' - ',Twn2,', ',s_b);
        end;
        end if;
      end;
      END IF;
      IF tab_on=9 THEN
      begin
        DECLARE N TINYINT; 
        DECLARE cli INT(5) unsigned;
      SELECT count(*),`clients` INTO N, cli FROM outs_hardware WHERE `outs_id`=inv_num_kli;
      if N=0 THEN RETURN 'ERROR';
      else
      begin
        DECLARE kli INT(5) unsigned;
        DECLARE str VARCHAR(250);
        DECLARE twi INT(5) unsigned;
        DECLARE cl VARCHAR(250);
        DECLARE tw VARCHAR(250);
        SELECT `klient`,`town_id`,`street` INTO kli,twi,str FROM office_kli WHERE `id_kli`=cli;
        SELECT `client` INTO cl FROM tab_klients WHERE `id`=kli;
        SELECT `town` INTO tw FROM tab_town WHERE `id`=twi;
        RETURN concat('OUTS - ',cl,', ',tw,', ',str);
      end;
        end if;
      end;
      END IF;
   
END$$
DELIMITER ;